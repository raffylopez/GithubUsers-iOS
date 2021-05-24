//
//  AppConfigHelperTests.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
@testable import GithubApp

class AppConfigHelperTests: XCTestCase {
    var appConfig: AppConfig?

    override func setUpWithError() throws {
        appConfig = getConfig()
    }

    override func tearDownWithError() throws {
    }

    func testConfigValid() throws {
        if let appConfig = appConfig {
            XCTAssert(!appConfig.githubUsersListUri.isEmpty)
            XCTAssert(!appConfig.githubUserDetailsUriPrefix.isEmpty)
            return
        }
        XCTFail()
    }

}
