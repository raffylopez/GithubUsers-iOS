//
//  GithubUsersAPIMock.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
@testable import GithubApp

class GithubUsersAPIMock: UserApi {
    typealias T = GithubUser
    typealias U = GithubUserInfo
    func fetchUsers(since: Int, completion: ((Result<[T], Error>) -> Void)?) {
        let url = Bundle.main.url(forResource: "fakeuserslist", withExtension: "json")!
        do {
            let data = try Data(contentsOf: url)
            let decoded = try newJSONDecoder().decode([T].self, from: data)
            completion?(.success(decoded))
        } catch let err {
            completion?(.failure(err))
        }
    }
    
    func fetchUserDetails(username: String, completion: ((Result<U, Error>) -> Void)?) {
        let url = Bundle.main.url(forResource: "fakeuserinfo", withExtension: "json")!
        do {
            let data = try Data(contentsOf: url)
            let decoded = try newJSONDecoder().decode(U.self, from: data)
            completion?(.success(decoded))
        } catch let err {
            completion?(.failure(err))
        }
    }
}
