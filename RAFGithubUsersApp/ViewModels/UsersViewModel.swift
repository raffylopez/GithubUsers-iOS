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

class UsersViewModel {

    private(set) var users: [User]! = [] {
        didSet {
            if users.count > 0 {
                self.onDataAvailable()
                delegate?.onDataAvailable()
            }
        }
    }

    private func resetState() {
        self.since = 0
        self.currentPage = 0
        self.lastBatchCount = 0
    }
    
    /* Resets state variables, removes images and entries in all stores*/
    public func clearData() {
        resetState()
        imageStore.removeAllImages()
//        do {
//            try databaseService.deleteAll()
//        } catch {
//            fatalError(error.localizedDescription) // TODO
//        }
        users.removeAll()
        // TODO: Create clear event notif
    }
    
    var delegate: ViewModelDelegate? = nil
    
    typealias OnDataAvailable = ( () -> Void )
    var onDataAvailable: OnDataAvailable = {}
    var onFetchInProgress: (() -> Void) = {}
    var onFetchNotInProgress: (() -> Void) = {}
    
    var since: Int = 0
    var currentPage: Int = 0
    var lastBatchCount: Int = 0
    
    var currentCount: Int {
        return users.count
    }
    
    let apiService: GithubUsersApi
    let databaseService: UsersProvider
    
    let imageStore: ImageStore!
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
    var presentedElements: [UserPresenter]! {
        return users.compactMap({ user in
            UserPresenter(user)
        })
    }
    
    init(apiService: GithubUsersApi, databaseService: UsersProvider) {
        self.apiService = apiService
        self.databaseService = databaseService
        imageStore = ImageStore()
    }

    /**
     Binds closure to model describing what to perform when data becomes available
     */
    func bind(availability: @escaping OnDataAvailable) {
        self.onDataAvailable = availability
    }
    
    /**
     Starts fetching user data from api service. Additional calls to this method
     are terminated at the onset, while a fetch is already in progress.
     
     Data availability notification is performed through an observable viewmodel
     closure
     */
    
    let userInfoProvider: UserInfoProvider = CoreDataService.shared
    
    func fetchUsers(onRetryError: ((Int)->())? = nil, completion: ((Result<[User], Error>)->Void)? = nil) {
        guard !isFetchInProgress else {
            return
        }
        
//        let message = self.currentPage <= 0 ? "Loading" : "Loading more"
        
        ToastAlertMessageDisplay.shared.makeToastActivity()
        
        try! self.databaseService.deleteAll()
        /* Pre-fetch state toggles */
        self.isFetchInProgress = true

        let onTaskSuccess = { (githubUsers: [GithubUser]) in
            /* Post-fetch */
            self.isFetchInProgress = false
            self.lastBatchCount = githubUsers.count
            self.currentPage += 1
            
            let users: [User] = githubUsers.map { githubUser in
                if let existingUserInfo = self.userInfoProvider.getUserInfo(with: githubUser.id) {
                    return self.databaseService.translate(from: githubUser, with: existingUserInfo)
                }
                return self.databaseService.translate(from: githubUser)
            }
            
            if let first = users.first, let login = first.login {
                print("FOOBAR: \(first)")
            }
            
            do {
                try self.databaseService.saveAll()
            } catch {
                completion?(.failure(error))
            }
            self.users.append(contentsOf: users)
            

            guard let user = self.users.last else { return }
            self.since = Int(user.id)
            completion?(.success(users))
            
            // TODO: Delegate success
        }
        
        let onTaskError: ((Int, Int, Error)->Void)? = { attemptCount, delayTillNext, error in
            completion?(.failure(error))
            self.delegate?.onRetryError(n: attemptCount, nextAttemptInMilliseconds: delayTillNext, error: error)
        }

        let queue = DispatchQueue(label: "serialized_queue", qos: .background)
        let retryAttempts = 5

        ScheduledTask(task: self.apiService.fetchUsers).retryWithBackoff(times: retryAttempts, taskParam: since, queue: queue, onTaskSuccess: onTaskSuccess, onTaskError: onTaskError)
        
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
            return // !!!
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
