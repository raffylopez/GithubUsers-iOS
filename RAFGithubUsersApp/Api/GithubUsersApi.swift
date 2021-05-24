//
//  GithubUsersAPI.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

class GithubUsersApi {
    let confForcedFail: Bool = false
    var confQueuedNetworkRequests: Bool = true

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
        
        URLSession.shared.githubUserInfoTask(with: URL(string: userInfoUri)!, completionHandler: { githubUserInfo, response, error in
            if let error = error {
                completion?(.failure(error))
                return
            }
            if let githubUserInfo = githubUserInfo {
                completion?(.success(githubUserInfo))
                return
            }
            completion?(.failure(AppError.emptyResult))
            }).resume()
    }
    
    func fetchUsers(since: Int = 0, completion: ((Result<[GithubUser], Error>) -> Void)? = nil) {
        DispatchQueue.global().async {
            ConcurrencyUtils.singleUserRequestSemaphore.wait()
            var uri = URLComponents(string: self.usersListUri)
            uri?.queryItems = [
                URLQueryItem(name: "access_token", value: getConfig().githubAccessToken),
                URLQueryItem(name: "since", value: "\(since)")
            ]
            print("Fetching list of users from \(uri!.url!.absoluteString)...")
            let task = URLSession.shared.githubUsersTask(with: uri!.url!, completionHandler: { (githubUsers, status, error) in
                print("Done fetching user list.")
                ConcurrencyUtils.singleUserRequestSemaphore.signal()
                if let error = error {
                    completion?(.failure(error))
                    return
                }
                if let githubUsers = githubUsers {
                    if self.confForcedFail {
                        completion?(.failure(AppError.generalError))
                        return
                    }
                    completion?(.success(githubUsers))
                    return
                }
                completion?(.failure(AppError.emptyResult))
            })
            task.resume()
        }
    }
}

class ConcurrencyUtils {
    static let singleImageRequestSemaphore = DispatchSemaphore(value: 1)
    static let singleUserRequestSemaphore = DispatchSemaphore(value: 1)
}
