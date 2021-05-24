//
//  ProfileViewModel.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class ProfileViewModel {
    
    init(cell: UserTableViewCellBase, apiService: GithubUsersApi, databaseService: UserInfoProvider) {
        self.apiService = apiService
        self.cell = cell
        self.user = cell.user
        self.databaseService = databaseService
        self.userInfo = cell.user.userInfo
        imageStore = ImageStore()
    }
    
    var delegate: ViewModelDelegate?
    let cell: UserTableViewCellBase
    let user: User

    typealias OnDataAvailable = ( () -> Void )
    var onDataAvailable: OnDataAvailable = {}
    var onFetchInProgress: (() -> Void) = {}
    var onFetchNotInProgress: (() -> Void) = {}
    
    let imageStore: ImageStore!
    let apiService: GithubUsersApi
    let databaseService: UserInfoProvider
    var isFetchInProgress: Bool = false {
        didSet {
            if (isFetchInProgress) {
                onFetchInProgress()
                delegate?.onFetchInProgress()
                return
            }
            onFetchNotInProgress()
            delegate?.onFetchDone()
        }
    }

    private let session: URLSession! = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    /**
     Binds closure to model describing what to perform when data becomes available
     */
    func bind(availability: @escaping OnDataAvailable) {
        self.onDataAvailable = availability
    }
    
    var userInfo: UserInfo? {
        didSet {
            delegate?.onDataAvailable()
        }
    }

    func fetchUserDetails(for user: User, onRetryError: ((Int)->())? = nil, completion: ((Result<UserInfo, Error>)->Void)? = nil) {
        guard !isFetchInProgress else {
            return
        }
        
        if let userInfo = self.user.userInfo, userInfo.seen {
            self.userInfo = userInfo
        }


        guard let login = user.login else {
            completion?(.failure(AppError.emptyResult))
            return
        }

        isFetchInProgress = true
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        let context = CoreDataService.persistentContainer.viewContext
        privateMOC.parent = context
        
        self.apiService.fetchUserDetails(username: login) { result in
            self.isFetchInProgress = false
            switch result {
            case let .success(githubUserInfo):
                privateMOC.performAndWait {
                    if let userInfo = self.user.userInfo {
                        userInfo.set(from: githubUserInfo, moc: privateMOC)
                        userInfo.seen = true
                    } else {
                        self.user.userInfo = UserInfo(from: githubUserInfo, moc: privateMOC)
                    }

                    do {
                        if privateMOC.hasChanges {
                            try privateMOC.save()
                        }
                        context.performAndWait {
                            do {
                                if context.hasChanges {
                                    try context.save()
                                }
                            } catch {
                                fatalError("Failed to save context: \(error)")
                            }
                        }
                    } catch {
                        completion?(.failure(error))
                        fatalError("Failed to save context: \(error)")
                    }
                    self.userInfo = self.user.userInfo
                    completion?(.success(self.user.userInfo!))
                }
            case let .failure(error):
                completion?(.failure(error))
            }

        }
    }

    /**
     Fetches photo media (based on avatar url). Call is asynchronous. Can be set to synchronous fetching, but
     doing so leads to severe performance degradation.
     */
    func fetchImage(for user: User, completion: @escaping (Result<(UIImage, ImageSource), Error>) -> Void, synchronous: Bool = false) {
        guard let urlString = user.urlAvatar, !urlString.isEmpty else {
            completion(.failure(AppError.missingImageUrl))
            return
        }
        let imageUrl = URL(string: urlString)!
        
        let key = "\(user.id)"
        if let image = imageStore.image(forKey: key) {
            DispatchQueue.main.async {
                completion(.success((image, .cache)))
            }
            return
        }
        
        let request = URLRequest(url: imageUrl)
        let group = DispatchGroup()
        if (synchronous) { group.enter() }
        
        let task = session.dataTask(with: request) { data, _, error in
            let result = self.processImageRequest(data: data, error: error)
            if case let .success(image) = result {
                self.imageStore.setImage(forKey: key, image: image.0)
            }
            
            if (synchronous) { group.leave() }
            
            OperationQueue.main.addOperation {
                completion(result)
            }
        }
        task.resume()
        if (synchronous) { group.wait() }
    }

    /**
     Performs Data to UIImage conversion
     */
    private func processImageRequest(data: Data?, error: Error?) -> Result<(UIImage, ImageSource), Error> {
        guard let imageData = data, let image = UIImage(data: imageData) else {
            if data == nil {
                return .failure(error!)
            }
            return .failure(AppError.imageCreationError)
        }
        return .success((image, .network))
    }
}
