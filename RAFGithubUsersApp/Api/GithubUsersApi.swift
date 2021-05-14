//
//  GithubUsersAPI.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

class GithubUsersApi {
    let configurableForceFailure: Bool = false
    
    typealias T = GithubUser
    let usersListUri: String
    let userInfoUriPrefix: String
    
    init() {
        userInfoUriPrefix = "\(getConfig().githubUserDetailsUriPrefix)"
        usersListUri = "\(getConfig().githubUsersListUri)"
    }

    func fetchUserDetails(username: String, completion: ((Result<GithubUserInfo, Error>) -> Void)? = nil ) {
        let userInfoUri = "\(userInfoUriPrefix)\(username)"
        guard var uri = URLComponents(string: userInfoUri) else {
            preconditionFailure("Can't construct urlcomponents")
        }

        uri.queryItems = [
            URLQueryItem(name: "access_token", value: getConfig().githubAccessToken)
        ]
        
        guard let url = uri.url else {
            preconditionFailure("Can't build url")
        }
        URLSession.shared.githubUserInfoTask(with: URL(string: userInfoUri)!, completionHandler: { githubUserInfo, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }
            if let githubUserInfo = githubUserInfo {
                completion?(.success(githubUserInfo))
                return
            }
            print(url)
            completion?(.failure(ErrorType.emptyResult))
            }).resume()
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
                if self.configurableForceFailure {
                    completion?(.failure(ErrorType.generalError))
                    return
                }
                completion?(.success(githubUsers))
                return
            }
            completion?(.failure(ErrorType.emptyResult))
        })
        task.resume()
        if synchronous { dispatchGroup.wait() }
    }
}
