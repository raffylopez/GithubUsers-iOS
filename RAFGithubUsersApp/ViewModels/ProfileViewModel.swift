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
    var delegate: ViewModelDelegate? = nil
    let user: User
    
    typealias OnDataAvailable = ( () -> Void )
    var onDataAvailable: OnDataAvailable = {}
    var onFetchInProgress: (() -> Void) = {}
    var onFetchNotInProgress: (() -> Void) = {}
    
    let imageStore: ImageStore!
    let apiService: GithubUsersApi
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
    
    private static let persistentContainerName = getConfig().xcPersisentContainerName
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Self.persistentContainerName )
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
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

    init(user: User, apiService: GithubUsersApi) {
        self.apiService = apiService
        self.user = user
        imageStore = ImageStore()
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
        
        guard let login = user.login else {
            completion?(.failure(AppError.emptyResult))
            return
        }

        isFetchInProgress = true
        
        let onTaskSuccess = { (githubuserInfo: GithubUserInfo) in
            self.isFetchInProgress = false
            
            let context = self.persistentContainer.viewContext
            // TODO: Transfer to managedUserInfo in CoreData UserInfo entity class
            let managedUserInfo = UserInfo(from: githubuserInfo, moc: context)
            self.userInfo = managedUserInfo
            do {
                try context.save()
            } catch {
                completion?(.failure(error))
            }
            completion?(.success(managedUserInfo))
            // TODO: Delegate success
        }
        
        let onTaskError: ((Int, Int, Error)->Void)? = { attemptCount, delayTillNext, error in
            self.isFetchInProgress = false
            completion?(.failure(error))
            self.delegate?.onRetryError(n: attemptCount, nextAttemptInMilliseconds: delayTillNext, error: error)
        }
        
        let queue = DispatchQueue(label: "serialized_queue", qos: .background)
        let retryAttempts = 5
        ScheduledTask(task: self.apiService.fetchUserDetails).retryWithBackoff(times: retryAttempts, taskParam: login, queue: queue, onTaskSuccess: onTaskSuccess, onTaskError: onTaskError)
        
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
