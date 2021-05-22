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
            usersMain = oldValue
            if users.count > 0 {
                self.onDataAvailable()
                delegate?.onDataAvailable()
            }
        }
    }
    
    /* MARK: - Debug */


    /* MARK: - Inits */
    init(apiService: GithubUsersApi, databaseService: UsersProvider) {
        self.apiService = apiService
        self.usersDatabaseService = databaseService
        imageStore = ImageStore()
//        self.updateFromDiskSource { }
    }
 
    let confOfflineIncrements: Int = 30
    var runoff: Int {
        return usersDatabaseService.getUserCount() % confOfflineIncrements
    }
//    public func clearUsers() {
//        self.users.removeAll(keepingCapacity: false)
//    }
    
    var usersMain: [User]? = []
    var filteredUsers: [User]? = []
    
    public func clearUsers() {
        usersMain = self.users
//        self.users.removeAll(keepingCapacity: false)
        self.users = []
    }
    private func switchToMain() {
        filteredUsers = self.users
        self.users = usersMain
    }
    private func switchToFiltered() {
        usersMain = self.users
        self.users = filteredUsers
    }

    public func searchUsers(for term: String) {
        if term.isEmpty  {
            self.usersDatabaseService.getUsers (limit: nil){ result in
                switch result {
                case let .success(users):
//                    self.filteredUsers = users
//                    self.switchToFiltered()
                    self.users = users
                    break
                case .failure:
                    break
                }
            }
            return
        }
        self.usersDatabaseService.filterUsers(with: term) { result in
            switch result {
            case let .success(users):
                self.users = users
                break
            case .failure:
                break
            }

        }
    }
    
    func loadOfflineData(completion: (()->Void)? = nil) {
        print("STATS totalDisplayCount: \(self.totalDisplayCount)")
        let userCount = self.usersDatabaseService.getUserCount()
        print("STATS userCount: \(userCount)")
        
        guard userCount > 0 else {
            completion?()
            return
        }
        
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
            case let .success(combinedUsers):
                let start = combinedUsers.count - self.confOfflineIncrements
                let end = combinedUsers.count
                self.registerStale(users: combinedUsers[(start..<end)].map { $0 })
                if let user = combinedUsers.last {
                    self.since = Int(user.id)
                }
                self.currentStartIndex = combinedUsers.count
                completion?()
            case let .failure(error):
                completion?()
                print(error.localizedDescription)
            }
        }

    }
    
    var confSimulateOffline = true
    /* MARK: - Interface */
    /**
     Public-facing routine to be accessed by viewcontroller. Wraps around processRequest.
     */
    public func updateUsers(completion: (()->Void)? = nil) {
        guard !confSimulateOffline else {
            loadOfflineData(completion: completion)
            return
        }
        guard ConnectionMonitor.shared.isApiReachable else {
            loadOfflineData(completion: completion)
            return
        }
        processUserRequest { result in
            switch result {
            case let .success(users):
                self.unregisterStale(users: users)
                if let user = users.last {
                    self.since = Int(user.id)
                }
                self.lastBatchCount = users.count
//                print_r(array: users) // DEBUG
                self.loadUsersFromDisk(count: self.totalDisplayCount)
                completion?()
            case let .failure(error):  // INCLUDES NO INTERNET
                print(error.localizedDescription)
                self.loadOfflineData(completion: completion)
                completion?()
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

    var currentStartIndex = 0
    /**
     Fetch data from coredata, and set it to users attribute, triggering
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
    
    private func synchronize(privateMOC: NSManagedObjectContext) {
     do {
       try privateMOC.save()
         DispatchQueue.main.async {
            let mainContext = CoreDataService.persistentContainer.viewContext
            mainContext.performAndWait {
             do {
               try mainContext.save()
               print("Saved to main context")
             } catch {
               print("Could not synchonize data. \(error), \(error.localizedDescription)")
             }
         }
       }
     } catch {
       print("Could not synchonize data. \(error), \(error.localizedDescription)")
     }
    }
    
    /**
     Fetches users from off the network, and writes users into datastore. Uses background context
     for write queries. Reads are performed by main view context.

     Additional calls to this method are terminated at onset, while a fetch is already in progress.
     
     Returns a result containing network-fetched users ONLY, which are a merge
     of network-based objects and old database objects. The count is based on the
     size of the batch received.
     */
    func processUserRequest(completion: @escaping ((Result<[User], Error>)->Void)) {
        guard !isFetchInProgress else {
            completion(.failure(AppError.fetchInProgress))
            return
        }
        self.isFetchInProgress = true
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        let privateMOC = CoreDataService.privateMOC
        let context = CoreDataService.persistentContainer.viewContext
        privateMOC.parent = context
        
        self.apiService.fetchUsers(since: self.since) { (result: Result<[GithubUser], Error>) in
            self.isFetchInProgress = false
            switch result {
            case let .success(githubUsers):
                self.currentPage += 1
                privateMOC.performAndWait {
                    let users: [User] = githubUsers.map { githubUser in
                        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                        fetchRequest.entity = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: context)
                        let predicate = NSPredicate( format: "\(#keyPath(User.id)) == \(githubUser.id)" )
                        fetchRequest.predicate = predicate
                        var fetchedUsers: [User]?
//                        context.performAndWait {
                            do {
                                fetchedUsers = try fetchRequest.execute()
                            } catch {
                                preconditionFailure()
                            }
//                        }
                        if let existingUser = fetchedUsers?.first {
                            existingUser.merge(with: githubUser, moc: privateMOC)
                            return existingUser
                        }
                        
                        var user: User!
                        user = User(from: githubUser, moc: privateMOC)
                        return user
                    }
                    
                    do { // TODO: transfer to sync method
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
                        completion(.failure(error))
                        fatalError("Failed to save context: \(error)")
                    }
                    completion(.success(users))
                    
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Stale data classification
    
    var staleIds:[Int64] = []
    private func registerStale(users: [User]) {
        users.forEach { user in
            staleIds.append(user.id)
        }
        staleIds = staleIds.unique
        staleIds.sort()
    }
    
    private func unregisterStale(users: [User]) {
        users.forEach { user in
            if let indexOf = staleIds.firstIndex(of: user.id) {
                staleIds.remove(at: indexOf)
            }
        }
    }

    public func refreshStale(completion: ((Result<[User], Error>)->Void)? = nil) {
        guard ConnectionMonitor.shared.isApiReachable else {
//            ToastAlertMessageDisplay.main.display(message: "Network unreachable.")
//            completion?(.failure(AppError.networkError))
            return
        }

        guard let since = staleIds.first else {
            ToastAlertMessageDisplay.main.display(message: "No stale entries left to update")
            completion?(.failure(AppError.emptyResult))
            return
        }
        refreshInBackground(since: Int(since == 0 ? 0 : since - 1)) { result in
            switch result {
            case let .success(users):
                self.unregisterStale(users: users)
//                print_r(array: users)
                print_r(array: self.staleIds)
                
                ToastAlertMessageDisplay.main.display(message: "\(self.staleIds.count) stale entries left to update")
                completion?(.success(users))
            case let .failure(error):
                print(error)
                completion?(.failure(error))
            }
        }
    }

    private func refreshInBackground(since: Int, completion: @escaping ((Result<[User], Error>)->Void)) {
        guard !isFetchInProgress else {
            return
        }
        self.isFetchInProgress = true
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
//        let privateMOC = CoreDataService.privateMOC
        let context = CoreDataService.persistentContainer.viewContext
        privateMOC.parent = context
        
        self.apiService.fetchUsers(since: since) { (result: Result<[GithubUser], Error>) in
            self.isFetchInProgress = false
            switch result {
            case let .success(githubUsers):
                privateMOC.performAndWait {
                    let users: [User] = githubUsers.map { githubUser in
                        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
                        fetchRequest.entity = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: context)
                        let predicate = NSPredicate( format: "\(#keyPath(User.id)) == \(githubUser.id)" )
                        fetchRequest.predicate = predicate
                        var fetchedUsers: [User]?
//                        context.performAndWait {
                            do {
                                fetchedUsers = try fetchRequest.execute()
                            } catch {
                                preconditionFailure()
                            }
//                        }
                        if let existingUser = fetchedUsers?.first {
                            existingUser.merge(with: githubUser, moc: privateMOC)
                            return existingUser
                        }
                        
                        var user: User!
                        user = User(from: githubUser, moc: privateMOC)
                        return user
                    }
                    
                    do { // TODO: transfer to sync method
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
                        completion(.failure(error))
                        fatalError("Failed to save context: \(error)")
                    }
                    completion(.success(users))
                    
                }
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }

    /**
     Fetches photo media (based on avatar url). Call is asynchronous or synchronous,but the latter
     leads to less than optimal performance.
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
extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}
