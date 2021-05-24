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
    let retryCountOnServerSideFail = 10
    var confDbgVerboseNetworkCalls = getConfig().dbgVerboseNetworkCalls
    
    typealias OnDataAvailable = ( () -> Void )
    var onDataAvailable: OnDataAvailable = {}
    var onFetchInProgress: (() -> Void) = {}
    var onFetchNotInProgress: (() -> Void) = {}
    
    var since: Int = 0
    var currentPage: Int = 0
    var lastBatchCount: Int = 0
    var totalDisplayCount: Int = 0
    var lastDataSource: DataSource = .unspecified
    
    var currentCount: Int {
        return users.count
    }
    
    let apiService: GithubUsersApi
    let usersDatabaseService: UsersProvider
    
    let imageStore: ImageStore!
    
    var isFetchInProgress: Bool = false {
        didSet {
            print(isFetchInProgress)
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
            self.lastDataSource = .local
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
            completion?(.failure(AppError.httpTransportError(AppError.networkUnreachable)))
            return
        }
        
        guard let since = staleIds.first else {
            completion?(.failure(AppError.emptyResultError))
            return
        }
        
        fetchUsers(since: Int(since == 0 ? 0 : since - 1)) { result in
            switch result {
            case let .success(users):
                self.unregisterStale(users: users)
                completion?(.success(users))
            case let .failure(error):
                print(error.localizedDescription)
                completion?(.failure(error))
            }
        }
    }
    
    /**
     Translate api instance to data model object, and persist to data storoe
     */
    func persist(apiUsers githubUsers: [GithubUser], persistCompletion: @escaping UserResult) {
        
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        let context = CoreDataService.persistentContainer.viewContext
        privateMOC.parent = context
        
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
                    persistCompletion(.failure(AppError.writeToDatastoreError(error)))
                }
                if let existingUser = fetchedUsers?.first {
                    existingUser.merge(with: githubUser, moc: privateMOC)
                    return existingUser
                }
                
                var user: User!
                user = User(from: githubUser, moc: privateMOC)
                return user
            } // end githubUsers.map
            
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
                        persistCompletion(.failure(AppError.writeToDatastoreError(error)))
                    }
                } // end context.performAndWait
            } catch {
                persistCompletion(.failure(AppError.writeToDatastoreError(error)))
            } // end do
            persistCompletion(.success(users))
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
    typealias UserResult = ((Result<[User], Error>)->Void)
    
    private func fetchUsers(since: Int, completion: @escaping UserResult) {
        guard !isFetchInProgress else {
            return
        }
        
        self.isFetchInProgress = true
        
        self.apiService.fetchUsers(since: since) { result in
            self.lastDataSource = .network
            switch result {
            case let .success(githubUsers):
                self.isFetchInProgress = false
                self.persist(apiUsers: githubUsers, persistCompletion: completion)
            case let .failure(error):
                print(error.localizedDescription)
                switch error {
                case AppError.httpServerSideError:
                    /** Retry with exponential backoff to avoid pommeling the backend */
                    for i in 1..<retryCountOnServerSideFail {
                        /* print("Scheduling backed-off retries...\(i)") */
                        let delay = TimeInterval.getExponentialDelay(for: i)
                        let secs = Float(delay) / 1000.0
                        DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(delay)) {
                            ToastAlertMessageDisplay.main.display(message: "Unable to connect to the server, trying in \(secs) seconds ")
                            self.retryFetchUsers(since: since) { result in
                                switch result {
                                case let .success(users):
                                    self.isFetchInProgress = false
                                    completion(.success(users))
                                    break
                                case let .failure(error):
                                    print(error)
                                    break
                                }
                            }
                        }
                    }
                    completion(.failure(AppError.retriesExceededError(error)))
                default:
                    self.isFetchInProgress = false
                    completion(.failure(AppError.httpTransportError(error)))
                }
            }
        }
    }
    
    /** For exclusive use of failure handler of fetchUsers*/
    private func retryFetchUsers(since: Int, completion: @escaping UserResult) {
        self.apiService.fetchUsers(since: since) { result in
            self.lastDataSource = .network
            switch result {
            case let .success(githubUsers):
                self.isFetchInProgress = false
                self.persist(apiUsers: githubUsers, persistCompletion: {
                    if case let .failure(error) = $0 {
                        completion(.failure(AppError.writeToDatastoreError(error))) // persistence error
                    }
                })
            case let .failure(error):
                print(error.localizedDescription)
                // do not allow others to come into fetch users, isFetchInProgress should remain true
                // send off another request, using dispatch async
                // perform a recursion unwind, once successful
                completion(.failure(error)) // connection error??
            }
        }
    }
    
    /**
     Fetches photo media (based on avatar url). Call is asynchronous or synchronous,but the latter
     leads to less than optimal performance.
     */
    func fetchImage(for user: User, reload: Bool = false, queued: Bool = true, completion: @escaping (Result<(UIImage, ImageSource), Error>) -> Void) {
        guard let urlString = user.urlAvatar, !urlString.isEmpty else {
            completion(.failure(AppError.missingImageUrlError))
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
