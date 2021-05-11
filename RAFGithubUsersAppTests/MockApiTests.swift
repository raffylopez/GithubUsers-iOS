//
//  RAFGithubUsersAppTests.swift
//  RAFGithubUsersAppTests
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
@testable import RAFGithubUsersApp

class MockApiTests: XCTestCase {
    var apiMock: GithubUsersAPIMock?
    override func setUpWithError() throws {
        apiMock = GithubUsersAPIMock()
    }

    override func tearDownWithError() throws {
    }

    func testApiMockFetchesResults() throws {
        apiMock?.fetchResult(completion: { (result) in
            switch result {
            case .failure:
                XCTFail()
            case .success:
                XCTAssert(true)
            }
        })
    }

    func testApiMockFetchesResultsNotEmpty() throws {
        apiMock?.fetchResult(completion: { (result) in
            switch result {
            case .failure:
                XCTAssert(false)
            case .success(let users):
                XCTAssert(!users.isEmpty)
            }
        })
    }
    
    func testApiMockFetchResultsCorrect() throws {
        apiMock?.fetchResult(completion: { (result) in
            switch result {
            case .failure:
                XCTAssert(false)
            case .success(let users):
                XCTAssert(users.count == 30)
                let user = users.first!
                XCTAssert(
                    user.login == "mojombo" &&
                    user.id == 1 &&
                    user.nodeID == "MDQ6VXNlcjE="
                )
            }
        })
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
