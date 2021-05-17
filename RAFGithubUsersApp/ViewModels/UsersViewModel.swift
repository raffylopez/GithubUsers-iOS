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
        self.currentPage = 1
        self.lastBatchCount = 30
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
//        clearDiskStore()
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
    
//    func fetchUsers(onRetryError: ((Int)->())? = nil, completion: ((Result<[User], Error>)->Void)? = nil) {
//
//
//
////        if let user = databaseService.getUser(id: 1) {
////            print (user)
////            print (user.login)
////            print (user.userInfo)
////        } else {
////            print("user not found")
////        }
//    }


    func fetchUsersFromDisk(completion: @escaping ((Result<[User], Error>)->Void)) {
        // if offline, display from coredata, then keep retrying
        databaseService.getUsers { (result) in
            switch result {
            case let .failure(error):
                completion(.failure(error))
            case let .success(users):
                completion(.success(users))
            }
        }
    }
    
    func updateDataSource(completion: ()->Void) {
        fetchUsersFromDisk { result in
            switch result {
            case let .failure(error):
                self.users.removeAll()
                print("CoreData read problem: \(error.localizedDescription)")
            case let .success(users):
                self.users.append(contentsOf: users)
            }
        }
    }

    private func processUserRequest(completion: @escaping (Result<[User], Error>)->Void) {
        let context = CoreDataService.persistentContainer.viewContext
        
        self.apiService.fetchUsers(since: self.since) { (result: Result<[GithubUser], Error>) in
            switch result {
            case let .success(githubUsers):
                let users: [User] = githubUsers.map { githubUser in
                    /* Does the user already exist in storage? */
                    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                    fetchRequest.entity = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: context)
                    let predicate = NSPredicate( format: "\(#keyPath(User.id)) == \(githubUser.id)" )
                    fetchRequest.predicate = predicate
                    var fetchedUsers: [User]?
                    do {
                        fetchedUsers = try context.fetch(fetchRequest)
                    } catch {
                        preconditionFailure()
                    }
                    if let existingUser = fetchedUsers?.first {
                        return existingUser
                    }
                    
                    var user: User!
                    context.performAndWait {
                        user = User(from: githubUser, moc: context)
                    }
                    return user
                }
                do {
                    try context.save()
                } catch {
                    completion(.failure(error))
                    preconditionFailure()
                }
                self.lastBatchCount = githubUsers.count
                completion(.success(users))

            case let .failure(error):
                completion(.failure(error))
            }
    }
    }
    

    let localAccessOnly: Bool = false
    /* Copies API-sourced data into datastore entities, which are then attached to the datasource */
    func fetchUsers(onRetryError: ((Int)->())? = nil, completion: ((Result<[User], Error>)->Void)? = nil) {
        guard !isFetchInProgress else {
            return
        }

        guard !localAccessOnly else { return }

        let context = CoreDataService.persistentContainer.viewContext
        ToastAlertMessageDisplay.shared.makeToastActivity()
        
        try! self.databaseService.deleteAll()
        
        /* Pre-fetch state toggles */
        self.isFetchInProgress = true

        /* Process User request*/
        let onTaskSuccess = { (githubUsers: [GithubUser]) in
            /* Post-fetch state toggles */
            self.isFetchInProgress = false
            
            self.lastBatchCount = githubUsers.count
            self.currentPage += 1
            
            /* Map out api collection, and write to coredata */
            let users: [User] = githubUsers.map { githubUser in
                /* Does the user already exist in storage? */
                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                fetchRequest.entity = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: context)
                let predicate = NSPredicate(format: "%K == %d", #keyPath(User.id), Int32(githubUser.id))
                fetchRequest.predicate = predicate
                var fetchedUsers: [User]?
                do {
                    fetchedUsers = try context.fetch(fetchRequest)
                } catch {
                    preconditionFailure()
                }
                
                if let existingUser = fetchedUsers?.first {
                    /* If so, return from storage*/
                    print(existingUser)
                    return existingUser
                }

                /* Otherwise, create new */
                var user: User!
                context.performAndWait {
                    user = User(from: githubUser, moc: context)
                }
                return user
            }
//                if let existingUserInfo = self.userInfoProvider.getUserInfo(with: githubUser.id) {
//                    return self.databaseService.translate(from: githubUser, with: existingUserInfo)
//                }
//                return self.databaseService.translate(from: githubUser)

            do {
                try context.save()
            } catch {
                preconditionFailure()
            }

            /* Update model datasource, which should trigger view controller */
            self.updateDataSource {
                self.since = Int(self.users.last?.id ?? 0)
                self.currentPage += 1
                completion?(.success(users))
            }

            // TODO: State variable toggles
            guard let user = self.users.last else {
                self.since = 0
                return
            }
            self.since = Int(user.id)
                
            // TODO: Delegate success
            completion?(.success(users))
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
