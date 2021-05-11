//
//  AmiiboConfig.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

// MARK: - Config
public struct AppConfig: Decodable {
    private enum CodingKeys: String, CodingKey {
        case githubUsersListUri = "URI_GITHUBAPI_USERSLIST"
        case githubUserDetailsUriPrefix = "URI_GITHUBAPI_USERDETAILS_PREFIX"
    }
    let githubUsersListUri: String
    let githubUserDetailsUriPrefix: String
}

public func getConfig() -> AppConfig? {
    let url = Bundle.main.url(forResource: "AppConfig", withExtension: "plist")!
    do {
        let data = try? Data(contentsOf: url)
        let decoder = PropertyListDecoder()
        let decoded = try? decoder.decode(AppConfig.self, from: data!)
        return decoded
    }
}
