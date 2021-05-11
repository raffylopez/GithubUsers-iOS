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

    override func setUpWithError() throws {
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testConfigValid() throws {
        if let appConfig = getConfig() {
            XCTAssert(appConfig.githubUsersListUri != "")
            XCTAssert(appConfig.githubUserDetailsUriPrefix != "")
            return
        }
        XCTAssert(false)
        
    }

}
