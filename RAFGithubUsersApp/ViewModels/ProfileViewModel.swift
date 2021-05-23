//
//  AmiiboElementsViewModel.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/17/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import UIKit
import CoreData

// MARK: - AmiiboElementsViewModel
class ProfileViewModel {
    
    init(cell: UserTableViewCellBase, apiService: GithubUsersApi, databaseService: UserInfoProvider) {
        self.apiService = apiService
        self.cell = cell
        self.user = cell.user
        self.databaseService = databaseService
        imageStore = ImageStore()
    }
    
    var delegate: ViewModelDelegate? = nil
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
            print("Fetch in progress: \(isFetchInProgress)")
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
    
    private(set) var userInfo: UserInfo! = nil {
        didSet {
            self.onDataAvailable()
            delegate?.onDataAvailable()
        }
    }

    /**
     Binds closure to model describing what to perform when data becomes available
     */
    func bind(availability: @escaping OnDataAvailable) {
        self.onDataAvailable = availability
    }
    
    
    func fetchUserDetails(for user: User, onRetryError: ((Int)->())? = nil, completion: ((Result<UserInfo, Error>)->Void)? = nil) {
        guard !isFetchInProgress else {
            return
        }
        
        if let userInfo = self.user.userInfo, userInfo.seen {
            self.userInfo = self.user.userInfo
            completion?(.success(self.user.userInfo!))
            return
        }


        guard let login = user.login else {
            completion?(.failure(AppError.emptyResult))
            return
        }

        isFetchInProgress = true
        
        let onTaskSuccess = { (githubuserInfo: GithubUserInfo) in
            self.isFetchInProgress = false

            self.user.userInfo?.set(from: githubuserInfo, moc: CoreDataService.shared.context)
            self.userInfo.seen = true
            do {
                try self.databaseService.save()
            } catch {
                completion?(.failure(error))
            }
            self.userInfo = self.user.userInfo
            completion?(.success(self.userInfo))
        }
        
        self.apiService.fetchUserDetails(username: login) { result in
            switch result {
            case let .success(githubUserInfo):
                self.isFetchInProgress = false
                
                self.user.userInfo?.set(from: githubUserInfo, moc: CoreDataService.shared.context)
                self.user.userInfo?.seen = true
                do {
                    try self.databaseService.save()
                } catch {
                    completion?(.failure(error))
                }
                self.userInfo = self.user.userInfo
                completion?(.success(self.userInfo))
            case let .failure(error):
                self.isFetchInProgress = false
                completion?(.failure(error))
            }

        }
//        let onTaskError: ((Int, Int, Error)->Void)? = { attemptCount, delayTillNext, error in
//            self.isFetchInProgress = false
//            completion?(.failure(error))
//            self.delegate?.onRetryError(n: attemptCount, nextAttemptInMilliseconds: delayTillNext, error: error)
//        }
//
//        let queue = DispatchQueue(label: "serialized_queue", qos: .background)
//        let retryAttempts = 5
//        ScheduledTask(task: self.apiService.fetchUserDetails).retryWithBackoff(times: retryAttempts, taskParam: login, queue: queue, onTaskSuccess: onTaskSuccess, onTaskError: onTaskError)
        
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
            // Save to cache
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
