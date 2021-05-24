//
//  MockApiTests.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
@testable import GithubApp

class MockApiTests: XCTestCase {
    var apiMock: GithubUsersAPIMock?
    override func setUpWithError() throws {
        apiMock = GithubUsersAPIMock()
    }

    override func tearDownWithError() throws {
        apiMock = nil
    }

    func testApiMockFetchesResults() throws {
        apiMock?.fetchUsers(since: 0, completion: { (result) in
            switch result {
            case .failure:
                XCTFail()
            case .success:
                XCTAssert(true)
            }
        })
    }

    func testApiMockFetchesResultsNotEmpty() throws {
        apiMock?.fetchUsers(since: 0, completion: { (result) in
            switch result {
            case .failure:
                XCTFail()
            case .success(let users):
                XCTAssert(!users.isEmpty)
            }
        })
    }
    
    func testApiMockFetchResultsCorrect() throws {
        apiMock?.fetchUsers(since:0, completion: { (result) in
            switch result {
            case .failure:
                XCTFail()
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
    
    func testUserInfoMockApi() throws {
        apiMock?.fetchUsers(since:0) { (result) in
            switch result {
            case .failure:
                XCTFail()
            case .success(let users):
                XCTAssert(users.count == 30)
                let githubUser = users.first!
                XCTAssert(githubUser.login == "mojombo")
                XCTAssert(githubUser.id == 1)
                XCTAssert(githubUser.nodeID == "MDQ6VXNlcjE=")
                
                self.apiMock?.fetchUserDetails(username: githubUser.login) { (result) in
                    switch result {
                    case let .success(userInfo):
                        XCTAssertNotNil(userInfo)
                        XCTAssert(userInfo.id == 1)
                        XCTAssert(userInfo.login == "mojombo")
                        XCTAssert(userInfo.nodeID == "MDQ6VXNlcjE=")
                        XCTAssert(userInfo.name == "Tom Preston-Werner")
                        break
                    case let .failure(error):
                        fatalError(error.localizedDescription)
                        break
                    }
                    
                }
                
            }
        }
    }

}
