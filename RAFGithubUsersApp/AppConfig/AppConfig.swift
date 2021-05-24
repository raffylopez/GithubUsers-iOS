//
//  struct.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

// MARK: - Config
public struct AppConfig: Decodable {
    private enum CodingKeys: String, CodingKey {
        case githubUsersListUri = "URI_GITHUBAPI_USERSLIST"
        case githubUserDetailsUriPrefix = "URI_GITHUBAPI_USERDETAILS_PREFIX"
        case githubAccessToken = "URI_GITHUBAPI_ACCESS_TOKEN"
        case xcPersisentContainerName = "XC_PERSISTENT_CONTAINER_NAME"
    }
    let githubUsersListUri: String
    let githubUserDetailsUriPrefix: String
    let xcPersisentContainerName: String
    let githubAccessToken: String
}

public func getConfig() -> AppConfig {
    let url = Bundle.main.url(forResource: "AppConfig", withExtension: "plist")!
    do {
        let data = try? Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        guard let decoded = try? decoder.decode(AppConfig.self, from: data!) else {
            fatalError("Unable to load configuration")
        }
        return decoded
    } 
}
