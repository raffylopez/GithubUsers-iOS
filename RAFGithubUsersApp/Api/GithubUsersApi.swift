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
    let userInfoUriPrefix: String
    
    init() {
        userInfoUriPrefix = "\(getConfig().githubUserDetailsUriPrefix)"
        usersListUri = "\(getConfig().githubUsersListUri)"
    }

    func fetchUserDetails(username: String, completion: ((Result<GithubUserInfo, Error>) -> Void)? = nil ) {
        let userInfoUri = "\(userInfoUriPrefix)\(username)"
        let semaphore = DispatchSemaphore(value: 0)
        var uri = URLComponents(string: userInfoUri)
        uri?.queryItems = [
            URLQueryItem(name: "access_token", value: getConfig().githubAccessToken)
        ]
        URLSession.shared.githubUserInfoTask(with: uri!.url!, completionHandler: { (githubUserInfo, _, error) in
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
    
    var synchronous = false
    
    func fetchUsers(since: Int = 0, completion: ((Result<[GithubUser], Error>) -> Void)? = nil) {
        let dispatchGroup = DispatchGroup()
        if synchronous {
            dispatchGroup.enter()
        }
        var uri = URLComponents(string: usersListUri)
        uri?.queryItems = [
            URLQueryItem(name: "access_token", value: getConfig().githubAccessToken),
            URLQueryItem(name: "since", value: "\(since)")
        ]

        let task = URLSession.shared.githubUsersTask(with: uri!.url!, completionHandler: { (githubUsers, _, error) in
            if self.synchronous { dispatchGroup.leave() }
            if let error = error {
                completion?(.failure(error))
                return
            }
            if let githubUsers = githubUsers {
                completion?(.failure(ErrorType.generalError))
//                completion?(.success(githubUsers))
                return
            }
            completion?(.failure(ErrorType.emptyResult))
        })
        task.resume()
        if synchronous { dispatchGroup.wait() }
    }
}
