//
//  UsersViewModel.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class UsersViewModel {
    /* MARK: - Properties */
    var delegate: ViewModelDelegate? = nil
    let maxRetryCountOnServerSideFail = 10_000
    var confDbgVerboseNetworkCalls = getConfig().dbgVerboseNetworkCalls

    typealias OnDataAvailable = ( () -> Void )
    var onDataAvailable: OnDataAvailable = {}
    var onFetchInProgress: (() -> Void) = {}
    var onFetchNotInProgress: (() -> Void) = {}
    
    var since: Int = 0
    var currentPage: Int = 0
    var lastBatchCount: Int = 0
    var totalDisplayCount: Int = 0
    var lastDataSource: LastDataSource = .unspecified
    
    var currentCount: Int {
        return users.count
    }
    
    let apiService: GithubUsersApi
    let usersDatabaseService: UsersProvider
    
    let imageStore: ImageStore!
    
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
    var presentedElements: [UserPresenter]! {
        return users.compactMap({ user in
            UserPresenter(user)
        })
    }
    let userInfoProvider: UserInfoProvider = CoreDataService.shared

    var needsMoreData: Bool {
        if let lastUser = users.last {
            return lastUser.id == since
        }
        return true
    }
    private(set) var users: [User]! = [] {
        didSet {
            if users.count > 0 {
                self.onDataAvailable()
                delegate?.onDataAvailable()
            }
        }
    }

    private(set) var filteredUsers: [User]! = [] {
        didSet {
            if filteredUsers.count > 0 {
                self.onDataAvailable()
                delegate?.onDataAvailable()
            }
        }
    }

    /* MARK: - Inits */
    init(apiService: GithubUsersApi, databaseService: UsersProvider) {
        self.apiService = apiService
        self.usersDatabaseService = databaseService
        imageStore = ImageStore()
    }
 
    let confOfflineIncrements: Int = 30
    var runoff: Int {
        return usersDatabaseService.getUserCount() % confOfflineIncrements
    }
    
    public func clearUsers() {
        self.users = []
    }

    public func searchUsers(for term: String) {
        if term.isEmpty  {
            self.usersDatabaseService.getUsers (limit: nil){ result in
                switch result {
                case let .success(users):
                    self.filteredUsers = users
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
                self.filteredUsers = users
                break
            case .failure:
                break
            }

        }
    }
    
    
    func loadOfflineData(completion: (()->Void)? = nil) {
        let userCount = self.usersDatabaseService.getUserCount()

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
            self.lastDataSource = .offline
            switch result {
            case let .success(combinedUsers):
                let start = combinedUsers.count - self.confOfflineIncrements
                let end = combinedUsers.count
                self.registerStale(users: combinedUsers[(start..<end)].map { $0 })
                if let user = combinedUsers.last {
                    self.since = Int(user.id)
                }
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
        if let lastUser = self.users.last {
            self.since = Int(lastUser.id)
        }
        fetchUsers(since: self.since) { result in
            switch result {
            case let .success(users):
                self.unregisterStale(users: users)
                if let user = users.last {
                    self.since = Int(user.id)
                }
                self.totalDisplayCount += users.count
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
    }

    /**
     Binds closure to model describing what to perform when data becomes available
     */
    func bind(availability: @escaping OnDataAvailable) {
        self.onDataAvailable = availability
    }

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
                print("\(error.localizedDescription)")
                completion?(.failure(error))
            case let .success(users):
                if let user = users.last {
                    self.since = Int(user.id)
                }
                self.users = users
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
             } catch {
               print("Could not synchonize data. \(error), \(error.localizedDescription)")
             }
         }
       }
     } catch {
       print("Could not synchonize data. \(error), \(error.localizedDescription)")
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
    
    /* Does not add new records into db */
    public func refreshStale(completion: ((Result<[User], Error>)->Void)? = nil) {
        guard ConnectionMonitor.shared.isApiReachable else {
            completion?(.failure(AppError.networkError))
            return
        }

        guard let since = staleIds.first else {
            completion?(.failure(AppError.emptyResult))
            return
        }
        
        fetchUsers(since: Int(since == 0 ? 0 : since - 1)) { result in
            switch result {
            case let .success(users):
                self.unregisterStale(users: users)
                completion?(.success(users))
            case let .failure(error):
                completion?(.failure(error))
            }
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
    private func fetchUsers(since: Int, completion: @escaping ((Result<[User], Error>)->Void)) {
        guard !isFetchInProgress else {
            return
        }
        
        self.isFetchInProgress = true
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        let context = CoreDataService.persistentContainer.viewContext
        privateMOC.parent = context
        
        self.apiService.fetchUsers(since: since) { result in
            self.lastDataSource = .network
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
                        do {
                            fetchedUsers = try fetchRequest.execute()
                        } catch {
                            preconditionFailure()
                        }
                        if let existingUser = fetchedUsers?.first {
                            existingUser.merge(with: githubUser, moc: privateMOC)
                            return existingUser
                        }
                        
                        var user: User!
                        user = User(from: githubUser, moc: privateMOC)
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
                        completion(.failure(error))
                        fatalError("Failed to save context: \(error)")
                    }
                    completion(.success(users))
                    
                }
            case let .failure(error):
                print(error.localizedDescription)
                switch error {
                case AppError.httpServerSideError:
                    guard !ScheduleTracker.retryIsActive else { break }
                    ScheduledTask(task: self.fetchUsers).retryWithBackoff(times: self.maxRetryCountOnServerSideFail, taskParam: since, onTaskSuccess: { _ in
                        DispatchQueue.main.async {
                            (UIApplication.shared.delegate as! AppDelegate).appConnectionState = .networkReachable
                        }
                    }, onTaskError: { _,_,_ in
                        DispatchQueue.main.async {
                            (UIApplication.shared.delegate as! AppDelegate).appConnectionState = .serverError
                        }
                    })
                default:
                    completion(.failure(error))
                }
                
                completion(.failure(error))
            }
        }
    }

    /**
     Fetches photo media (based on avatar url). Call is asynchronous or synchronous,but the latter
     leads to less than optimal performance.
         */
    func fetchImage(for user: User, reload: Bool = false, queued: Bool = true, completion: @escaping (Result<(UIImage, ImageSource), Error>) -> Void) {
        guard let urlString = user.urlAvatar, !urlString.isEmpty else {
            completion(.failure(AppError.missingImageUrl))
            return
        }
        let imageUrl = URL(string: urlString)!
        
        let key = "\(user.id)"
        if !reload {
            if let image = imageStore.image(forKey: key) {
                DispatchQueue.main.async {
                    completion(.success((image, .cache)))
                }
                return
            }
        }

        let request = URLRequest(url: imageUrl)

        DispatchQueue.global().async {
            ConcurrencyUtils.singleImageRequestSemaphore.wait()
            if self.confDbgVerboseNetworkCalls {
                print("Downloading and caching image from " + imageUrl.absoluteString + "...")
            }
            let task = self.session.dataTask(with: request) { data, _, error in
                let result = self.processImageRequest(data: data, error: error)
                // Save to cache
                if case let .success(image) = result {
                    self.imageStore.setImage(forKey: key, image: image.0)
                }
                
                OperationQueue.main.addOperation {
                    if self.confDbgVerboseNetworkCalls {
                        print("Done with image")
                    }
                    completion(result)
                    ConcurrencyUtils.singleImageRequestSemaphore.signal()
                }
            }
            task.resume()
        }
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
