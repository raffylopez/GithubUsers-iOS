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


protocol UsersViewModelDelegate {
    func onDataAvailable()
    func onRetryError(n: Int, nextAttemptInMilliseconds: Int, error:Error)
    func onFetchInProgress()
    func onFetchDone()
}

// MARK: - AmiiboElementsViewModel
class UsersViewModel {
    var delegate: UsersViewModelDelegate? = nil
    
    typealias OnDataAvailable = ( () -> Void )
    var onDataAvailable: OnDataAvailable = {}
    var onFetchInProgress: (() -> Void) = {}
    var onFetchNotInProgress: (() -> Void) = {}
    
    var currentCount: Int {
        return users.count
    }
    
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

    private(set) var users: [User]! = [] {
        didSet {
            self.onDataAvailable()
            delegate?.onDataAvailable()
        }
    }
    var presentedElements: [UserPresenter]! {
        return users.compactMap({ user in
            UserPresenter(user)
        })
    }
    
    init(apiService: GithubUsersApi) {
        self.apiService = apiService
        imageStore = ImageStore()
    }

    /**
     Binds closure to model describing what to perform when data becomes available
     */
    func bind(availability: @escaping OnDataAvailable) {
        self.onDataAvailable = availability
    }
    
    /**
     API call to user profiles
     */
    func fetchUserDetails(for user: User , completion: @escaping (Result<UserInfo, Error>)->Void) {
        guard let login = user.login else {
            return completion(.failure(ErrorType.emptyResult))
        }
        self.apiService.fetchUserDetails(username: login) { result in
            let context = self.persistentContainer.viewContext
            switch result {
            case let .success(githubuserInfo):
                let userInfo = UserInfo(context: context)
                userInfo.id = Int32(githubuserInfo.id)
                userInfo.bio = githubuserInfo.bio
                userInfo.company = githubuserInfo.company
                userInfo.createdAt = githubuserInfo.createdAt
                userInfo.email = githubuserInfo.email
                userInfo.followers = Int32(githubuserInfo.followers)
                userInfo.following = Int32(githubuserInfo.following)
                userInfo.isHireable = githubuserInfo.hireable == ""
                userInfo.location = githubuserInfo.location
                userInfo.name = githubuserInfo.name
                userInfo.publicGists = Int32(githubuserInfo.publicGists)
                userInfo.publicRepos = Int32(githubuserInfo.publicRepos)
                userInfo.twitterUsername = githubuserInfo.twitterUsername
                userInfo.updatedAt = githubuserInfo.updatedAt
                return completion(.success(userInfo))
            case .failure(let error):
                preconditionFailure("\(error.localizedDescription)")
            }
        }

    }

    var since: Int = 0
    var currentPage: Int = 0
    var lastBatchCount: Int = 0
    /**
     Starts fetching user data from api service. Additional calls to this method
     are terminated at the onset, while a fetch is already in progress.
     
     Data availability notification is performed through an observable viewmodel
     closure
     */
    func fetchUsers(onRetryError: ((Int)->())? = nil, completion: ((Result<[User], Error>)->Void)? = nil) {
        guard !isFetchInProgress else {
            return
        }
        
        isFetchInProgress = true

        let onTaskSuccess = { (githubUsers: [GithubUser]) in
            let context = self.persistentContainer.viewContext
                self.isFetchInProgress = false
                self.lastBatchCount = githubUsers.count
                self.currentPage += 1
                
                let users: [User] = githubUsers.map { githubUser in
                    var user: User!
                    context.performAndWait {
                        user = User(context: context)
                        user.login = githubUser.login
                        user.id = Int32(githubUser.id)
                        user.nodeId = githubUser.nodeID
                        user.urlAvatar = githubUser.avatarURL
                        user.gravatarId = githubUser.gravatarID
                        user.url = githubUser.url
                        user.urlHtml = githubUser.htmlURL
                        user.urlFollowers = githubUser.followersURL
                        user.urlFollowing = githubUser.followingURL
                        user.urlGists = githubUser.gistsURL
                        user.urlStarred = githubUser.starredURL
                        user.urlSubscriptions = githubUser.subscriptionsURL
                        user.urlOrganizations = githubUser.organizationsURL
                        user.urlRepos = githubUser.reposURL
                        user.urlEvents = githubUser.eventsURL
                        user.urlReceivedEvents = githubUser.receivedEventsURL
                        user.userType = githubUser.type
                        user.isSiteAdmin = githubUser.siteAdmin
                    }
                    return user
                }
                self.users.append(contentsOf: users)
                guard let user = self.users.last else { return }
                self.since = Int(user.id)
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
            completion(.failure(ErrorType.missingImageUrl))
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
            return .failure(ErrorType.imageCreationError)
        }
        return .success((image, .network))
    }
}
