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
    /* MARK: - Properties */
    var delegate: ViewModelDelegate? = nil
    
    typealias OnDataAvailable = ( () -> Void )
    var onDataAvailable: OnDataAvailable = {}
    var onFetchInProgress: (() -> Void) = {}
    var onFetchNotInProgress: (() -> Void) = {}
    
    var since: Int = 0
    var currentPage: Int = 0
    var lastBatchCount: Int = 0 {
        didSet {
            totalDisplayCount += lastBatchCount
        }
    }
    var totalDisplayCount: Int = 0

    var currentCount: Int {
        return users.count
    }
    
    let apiService: GithubUsersApi
    let usersDatabaseService: UsersProvider
    
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
    let userInfoProvider: UserInfoProvider = CoreDataService.shared

    private(set) var users: [User]! = [] {
        didSet {
            if users.count > 0 {
                self.onDataAvailable()
                delegate?.onDataAvailable()
            }
        }
    }
    
    /* MARK: - Debug */

    func dbgClearDataStoresOnAppLaunch() {
        try? usersDatabaseService.deleteAll()
        updateUsers() {
            print("STATS \(#function)")
            self.loadUsersFromDisk()
        }
    }
    
    /* MARK: - Inits */
    init(apiService: GithubUsersApi, databaseService: UsersProvider) {
        self.apiService = apiService
        self.usersDatabaseService = databaseService
        imageStore = ImageStore()
        // dbgClearDataStoresOnAppLaunch() // DEBUG
//        self.updateFromDiskSource { }
    }
 
    let confOfflineIncrements: Int = 30
    var runoff: Int {
        return usersDatabaseService.getUserCount() % confOfflineIncrements
    }
    
    /* MARK: - Interface */
    public func updateUsers(completion: (()->Void)? = nil) {
        processUserRequest { result in
            switch result {
            case let .success(users):
                if let user = users.last {
                    self.since = Int(user.id)
                }
                self.lastBatchCount = users.count
//                print_r(array: users) // DEBUG
                self.loadUsersFromDisk(count: self.totalDisplayCount)
                completion?()
            case let .failure(error):  // INCLUDES NO INTERNET
                print(error.localizedDescription)
                print("STATS totalDisplayCount: \(self.totalDisplayCount)")
                let userCount = self.usersDatabaseService.getUserCount()
                print("STATS userCount: \(userCount)")

                switch self.totalDisplayCount % userCount {
                case 0 where self.totalDisplayCount < userCount, self.totalDisplayCount: /* Start or middle */
                    self.totalDisplayCount += self.confOfflineIncrements
                case 0 where self.totalDisplayCount >= userCount: /* Ending with equal values */
                    return
                default: /* Ending with runoffs */
                    self.totalDisplayCount += self.usersDatabaseService.getUserCount() % self.confOfflineIncrements
                }
                
                self.loadUsersFromDisk(count: self.totalDisplayCount) { result in
                    switch result {
                    case .success(_):
                        ToastAlertMessageDisplay.main.hideAllToasts()
                        ToastAlertMessageDisplay.main.stickyToast(message: "Working offline")
                        completion?()
                    case let .failure(error):
                        completion?()
                        print(error.localizedDescription)
                    }

                }
            }
        }
    }

    private func resetState() {
        self.since = 0
        self.currentPage = 0
        self.lastBatchCount = 0
        self.totalDisplayCount = 0
    }
    
    /* Freshen stored objects with new data from the network  */
    public func clearData() {
        resetState()
//        clearDiskStore()
//        imageStore.removeAllImages()
//        self.users = []
//        self.users.removeAll()
        // TODO: Create clear event notif
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
//    private func fetchUsersFromDisk(completion: @escaping ((Result<[User], Error>)->Void)) {
//        // if offline, display from coredata, then keep retrying
//        usersDatabaseService.getUsers(limit: totalDisplayCount) { (result) in
//            switch result {
//            case let .failure(error):
//                completion(.failure(error))
//            case let .success(users):
//                completion(.success(users))
//            }
//        }
//    }
    
    /**
     Used for updating table view.
     
     Fetch data from coredata, and set it to users attribute, thereby triggering
     view controller closure.
     
     This function makes absolutely no network calls.
     */
    private func loadUsersFromDisk(count: Int? = nil, completion: ((Result<[User], Error>)->Void)? = nil) {
        usersDatabaseService.getUsers(limit: count) { (result) in
            switch result {
            case let .failure(error):
                self.users.removeAll()
                print("STATS read problem: \(error.localizedDescription)")
                completion?(.failure(error))
            case let .success(users):
                if let user = users.last {
                    self.since = Int(user.id)
                }
                
                self.users = users
                print("STATS TOTAL USERS TABLEDATASOURCE COUNT (UpdateDataSource): \(self.users.count)" )
                print("STATS TOTAL USERS COREDATA COUNT: \(self.usersDatabaseService.getUserCount())" )
                completion?(.success(users))
            }
        }
    }

    /**
     Fetches users from off the network, and writes users into the datastore.

     Returns a result containing network-fetched users ONLY, which are a combination
     of network-based objects and old database objects. The count is based on the
     size of the batch received.
     */
    func processUserRequest(completion: ((Result<[User], Error>)->Void)? = nil) {
        guard !isFetchInProgress else {
            return
        }
        self.isFetchInProgress = true
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        let context = CoreDataService.persistentContainer.viewContext
        privateMOC.parent = context
        
        self.apiService.fetchUsers(since: self.since) { (result: Result<[GithubUser], Error>) in
            self.isFetchInProgress = false
            switch result {
            case let .success(githubUsers):
                self.currentPage += 1
                privateMOC.perform {
                    let users: [User] = githubUsers.map { githubUser in
                        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                        fetchRequest.entity = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: context)
                        let predicate = NSPredicate( format: "\(#keyPath(User.id)) == \(githubUser.id)" )
                        fetchRequest.predicate = predicate
                        var fetchedUsers: [User]?
                        context.performAndWait {
                            do {
                                fetchedUsers = try fetchRequest.execute()
                            } catch {
                                preconditionFailure()
                            }
                        }
                        if let existingUser = fetchedUsers?.first {
                            existingUser.merge(with: githubUser, moc: context)
                            return existingUser
                        }
                        
                        var user: User!
                        user = User(from: githubUser, moc: context)
                        return user
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
                    completion?(.success(users))
                    
                }
            case let .failure(error):
                completion?(.failure(error))
            }
        }
    }

//    /* Combination of processRequest and updatedatasource */
//    /* TODO: closure-based notifiers */
//    func fetchUsers(onRetryError: ((Int)->())? = nil, completion: ((Result<[User], Error>)->Void)? = nil) {
//
//        print("STATS USER COUNT (PRE-FETCH): \(usersDatabaseService.getUserCount())" )
//        guard !isFetchInProgress else {
//            return
//        }
//
//        processUserRequest { result in
//            self.isFetchInProgress = false
//            switch result {
//            case let .success(users):
//                print("STATS USER COUNT (POST-FETCH): \(self.usersDatabaseService.getUserCount())" )
//                if let user = users.last {
//                    self.since = Int(user.id)
//                }
//                print("STATS SINCE: \(self.since)" )
//                print("STATS USERS RETURNED: \(users.count)" )
//                self.updateDataSource()
//            case let .failure(_):
//                preconditionFailure("BLAH")
//            }
//        }
//    }
//    let localAccessOnly: Bool = true

//    /* Combination of processRequest and updatedatasource */
//    func fetchUsers_(onRetryError: ((Int)->())? = nil, completion: ((Result<[User], Error>)->Void)? = nil) {
////        try? usersDatabaseService.deleteAll()
//
//        print("STATS USER COUNT (PRE-FETCH): \(usersDatabaseService.getUserCount())" )
//        guard !isFetchInProgress else {
//            return
//        }
//
//        processUserRequest { result in
//            self.isFetchInProgress = false
//            switch result {
//            case let .success(users):
//                print("STATS USER COUNT (POST-FETCH): \(self.usersDatabaseService.getUserCount())" )
//                if let user = users.last {
//                    self.since = Int(user.id)
//                }
//                print("STATS SINCE: \(self.since)" )
//                print("STATS USERS RETURNED: \(users.count)" )
//                self.loadUsersFromDisk()
//            case let .failure(error):
//                preconditionFailure("Error in \(#function): \(error)")
//            }
//        }
        
//        fetchUsersFromDisk { result in
//            switch result {
//            case let .success(users):
//                self.updateDataSource { }
//            case let .failure(error):
//                preconditionFailure()
//            }
//        }
//
//        guard !localAccessOnly else { return }
//
//        let context = CoreDataService.persistentContainer.viewContext
//        ToastAlertMessageDisplay.main.makeToastActivity()
//
//        try! self.usersDatabaseService.deleteAll()
//
//        /* Pre-fetch state toggles */
//        self.isFetchInProgress = true
//
//        /* Process User request*/
//        let onTaskSuccess = { (githubUsers: [GithubUser]) in
//            /* Post-fetch state toggles */
//            self.isFetchInProgress = false
//
//            self.lastBatchCount = githubUsers.count
//            self.currentPage += 1
//
//            /* Map out api collection, and write to coredata */
//            let users: [User] = githubUsers.map { githubUser in
//                /* Does the user already exist in storage? */
//                let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//                fetchRequest.entity = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: context)
//                let predicate = NSPredicate( format: "\(#keyPath(User.id)) == \(githubUser.id)" )
//                fetchRequest.predicate = predicate
//                var fetchedUsers: [User]?
//                do {
//                    fetchedUsers = try context.fetch(fetchRequest)
//                } catch {
//                    preconditionFailure()
//                }
//
//                if let existingUser = fetchedUsers?.first {
//                    /* If so, return from storage*/
//                    print(existingUser)
//                    return existingUser
//                }
//
//                /* Otherwise, create new */
//                var user: User!
//                context.performAndWait {
//                    user = User(from: githubUser, moc: context)
//                }
//                return user
//            }
////                if let existingUserInfo = self.userInfoProvider.getUserInfo(with: githubUser.id) {
////                    return self.databaseService.translate(from: githubUser, with: existingUserInfo)
////                }
////                return self.databaseService.translate(from: githubUser)
//
//            do {
//                try context.save()
//            } catch {
//                preconditionFailure()
//            }
//
//            /* Update model datasource, which should trigger view controller */
//            self.loadUsersFromDisk {
//                self.since = Int(self.users.last?.id ?? 0)
//                self.currentPage += 1
//                completion?(.success(users))
//            }
//
//            // TODO: State variable toggles
//            guard let user = self.users.last else {
//                self.since = 0
//                return
//            }
//            self.since = Int(user.id)
//
//            // TODO: Delegate success
//            completion?(.success(users))
//        }
//
//        let onTaskError: ((Int, Int, Error)->Void)? = { attemptCount, delayTillNext, error in
//            completion?(.failure(error))
//            self.delegate?.onRetryError(n: attemptCount, nextAttemptInMilliseconds: delayTillNext, error: error)
//        }
//
//        let queue = DispatchQueue(label: "serialized_queue", qos: .background)
//        let retryAttempts = 5
//
////        ScheduledTask(task: self.apiService.fetchUsers).retryWithBackoff(times: retryAttempts, taskParam: since, queue: queue, onTaskSuccess: onTaskSuccess, onTaskError: onTaskError)
//
//        self.apiService.fetchUsers(since: self.since) { result in
//            if case let .success(githubUsers) = result {
//                /* Post-fetch state toggles */
//                self.isFetchInProgress = false
//
//                self.lastBatchCount = githubUsers.count
//                self.currentPage += 1
//
//                /* Map out api collection, and write to coredata */
//                let users: [User] = githubUsers.map { githubUser in
//                    /* Does the user already exist in storage? */
//                    let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
//                    fetchRequest.entity = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: context)
//                    let predicate = NSPredicate( format: "\(#keyPath(User.id)) == \(githubUser.id)" )
//                    fetchRequest.predicate = predicate
//                    var fetchedUsers: [User]?
//                    do {
//                        fetchedUsers = try context.fetch(fetchRequest)
//                    } catch {
//                        preconditionFailure()
//                    }
//
//                    if let existingUser = fetchedUsers?.first {
//                        /* If so, return from storage*/
//                        print(existingUser)
//                        return existingUser
//                    }
//
//                    /* Otherwise, create new */
//                    var user: User!
//                    context.performAndWait {
//                        user = User(from: githubUser, moc: context)
//                    }
//                    return user
//                }
//                //                if let existingUserInfo = self.userInfoProvider.getUserInfo(with: githubUser.id) {
//                //                    return self.databaseService.translate(from: githubUser, with: existingUserInfo)
//                //                }
//                //                return self.databaseService.translate(from: githubUser)
//
//                do {
//                    try context.save()
//                } catch {
//                    preconditionFailure()
//                }
//
//                /* Update model datasource, which should trigger view controller */
//                self.loadUsersFromDisk {
//                    self.since = Int(self.users.last?.id ?? 0)
//                    self.currentPage += 1
//                    completion?(.success(users))
//                }
//
//                // TODO: State variable toggles
//                guard let user = self.users.last else {
//                    self.since = 0
//                    return
//                }
//                self.since = Int(user.id)
//
//                // TODO: Delegate success
//                completion?(.success(users))
//            }
//        }
//    }

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
