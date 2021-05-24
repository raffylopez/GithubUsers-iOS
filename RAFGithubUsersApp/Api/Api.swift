//
//  Api.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

protocol Api {
    associatedtype T
    associatedtype U
    func fetchUsers(since: Int, completion: ((Result<[T], Error>) -> Void)?)
    func fetchUserDetails(username: String, completion: ((Result<U, Error>) -> Void)?)
}
protocol UserApi: Api where T == GithubUser, U == GithubUserInfo {
}
