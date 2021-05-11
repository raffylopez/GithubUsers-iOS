//
//  ConfigHelperTests.swift
//  RAFGithubUsersAppTests
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
@testable import RAFGithubUsersApp

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
        XCTAssert(false)
        
    }

}
