//
//  GithubUsersAPI.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

class GithubUsersApi {
    typealias T = GithubUser
    let usersListUri: String
    let queryParams: String
    let userInfoUriPrefix: String
    
    init() {
        queryParams = "?access_token=\(getConfig().githubAccessToken)"
        userInfoUriPrefix = "\(getConfig().githubUserDetailsUriPrefix)\(queryParams)"
        usersListUri = "\(getConfig().githubUsersListUri)"
    }

    func fetchUserDetails(username: String, completion: ((Result<GithubUserInfo, Error>) -> Void)? = nil ) {
        let userInfoUri = "\(userInfoUriPrefix)\(username)"
        let semaphore = DispatchSemaphore(value: 0)
        URLSession.shared.githubUserInfoTask(with: URL(string: userInfoUri + queryParams)!, completionHandler: { (githubUserInfo, _, error) in
            if let error = error {
                semaphore.signal()
                completion?(.failure(error))
                return
            }
            if let githubUserInfo = githubUserInfo {
                semaphore.signal()
                completion?(.success(githubUserInfo))
                return
            }
            completion?(.failure(ErrorType.emptyResult))
            }).resume()
        semaphore.wait()
    }
    
    func fetchUsersList(completion: ((Result<[GithubUser], Error>) -> Void)? = nil ) {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()

        let task = URLSession.shared.githubUsersTask(with: URL(string: usersListUri + queryParams)!, completionHandler: { (githubUsers, _, error) in
            dispatchGroup.leave()
            if let error = error {
                completion?(.failure(error))
                return
            }
            if let githubUsers = githubUsers {
                completion?(.success(githubUsers))
                return
            }
            completion?(.failure(ErrorType.emptyResult))
        })
        task.resume()
        dispatchGroup.wait()
    }
}
