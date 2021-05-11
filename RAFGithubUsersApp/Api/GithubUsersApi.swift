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
    let usersListUri = getConfig().githubUsersListUri
    let userInfoUriPrefix = getConfig().githubUserDetailsUriPrefix
    
    func fetchUserDetails(username: String, completion: ((Result<GithubUserInfo, Error>) -> Void)? = nil ) {
        let userInfoUri = "\(userInfoUriPrefix)\(username)"
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.githubUserInfoTask(with: URL(string: userInfoUri)!, completionHandler: { (githubUserInfo, _, error) in
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
        })
        task.resume()
        semaphore.wait()
    }
    
    func fetchUsersList(completion: ((Result<[GithubUser], Error>) -> Void)? = nil ) {
        let semaphore = DispatchSemaphore(value: 0) /* force synchronous queueing */
        let task = URLSession.shared.githubUsersTask(with: URL(string: usersListUri)!, completionHandler: { (githubUsers, _, error) in
            if let error = error {
                semaphore.signal()
                completion?(.failure(error))
                return
            }
            if let githubUsers = githubUsers {
                semaphore.signal()
                completion?(.success(githubUsers))
                return
            }
        })
        task.resume()
        semaphore.wait()
    }
}
