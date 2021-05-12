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
class UsersViewModel {
    typealias OnDataAvailable = ( () -> Void )
    var onDataAvailable: OnDataAvailable = {}
    let imageStore: ImageStore!
    let apiService: GithubUsersApi

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
    
    func bind(availability: @escaping OnDataAvailable) {
        self.onDataAvailable = availability
        fetchUsers()
    }
    
    func fetchUserDetails(for user: User , completion: @escaping (Result<UserInfo, Error>)->Void) {
        guard let login = user.login else {
            return completion(.failure(ErrorType.emptyResult))
        }
        self.apiService.fetchUserDetails(username: login) { result in
            let context = self.persistentContainer.viewContext
            switch result {
            case let .success(githubuserInfo):
                let userInfo = UserInfo(context: context)
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

    func fetchUsers() {
        self.apiService.fetchUsersList { (result :Result<[GithubUser], Error>) in
            let context = self.persistentContainer.viewContext
            switch result {
            case let .success(githubUsers):
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
                self.users = users
            case .failure(let error):
                preconditionFailure("\(error.localizedDescription)")
            }
        }
    }
    
//    func fetchImage(for element: AmiiboElement, completion: @escaping (Result<(UIImage, ImageSource), Error>) -> Void) {
//        guard let imageUrl = element.imageUrl else {
//            completion(.failure(AmiiboError.missingImageUrl))
//            return
//        }
//
//        let key = "\(imageUrl.absoluteString.hashValue)"
//        if let image = imageStore.image(forKey: key) {
//            DispatchQueue.main.async {
//                completion(.success((image, .cache)))
//            }
//        }
//
//        let request = URLRequest(url: imageUrl)
//        let task = session.dataTask(with: request) { data, _, error in
//            let result = self.processImageRequest(data: data, error: error)
//            // Save to cache
//            if case let .success(image) = result {
//                self.imageStore.setImage(forKey: key, image: image.0)
//            }
//
//            OperationQueue.main.addOperation {
//                completion(result)
//            }
//        }
//        task.resume()
//    }
    
//    private func processImageRequest(data: Data?, error: Error?) -> Result<(UIImage, ImageSource), Error> {
//        guard let imageData = data, let image = UIImage(data: imageData) else {
//            if data == nil {
//                return .failure(error!)
//            }
//            return .failure(ErrorType.imageCreationError)
//        }
//        return .success((image, .network))
//    }
}
