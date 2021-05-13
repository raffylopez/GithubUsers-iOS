//
//  AmiiboMockApi.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/17/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

class GithubUsersAPIMock: UserApi {
    typealias T = GithubUser

    func fetchResult(completion: ((Result<[GithubUser], Error>) -> Void)? = nil ) {
        let url = Bundle.main.url(forResource: "fakeuserslist", withExtension: "json")!
        do {
            let data = try Data(contentsOf: url)
            let decoded = try newJSONDecoder().decode([GithubUser].self, from: data)
            completion?(.success(decoded))
        } catch let err {
            completion?(.failure(err))
        }
    }
}
