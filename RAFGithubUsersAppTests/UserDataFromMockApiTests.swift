//
//  TestCase.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
import CoreData
@testable import GithubApp

class UserDataFromMockApiTests: XCTestCase {
    var apiMock: GithubUsersAPIMock?
    
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var entityDescription: NSEntityDescription!
    var entityDescriptionUserInfo: NSEntityDescription!
    
    private func saveContext () {
    }
    
    // MARK: - Utility methods
    private func fetchUserUsing(id: Int32, context: NSManagedObjectContext) throws -> User?  {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(User.id)) == %i", id)
        fetchRequest.predicate = predicate
        let result = try? context.fetch(fetchRequest)
        return result?.first
    }
    
    // MARK: - Test setup
    override func setUp() {
        apiMock = GithubUsersAPIMock()
        
        /* Setup an in-memory persistent store */
        persistentContainer = {
            let container = NSPersistentContainer(name:  "RAFGithubUsersApp" )
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
            
            container.loadPersistentStores(completionHandler: { (storeDescription, error) in
                if let error = error as NSError? {
                    fatalError("Unresolved error \(error), \(error.userInfo)")
                }
            })
            return container
        }()
        context = persistentContainer.viewContext
        entityDescription = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: context)
        entityDescriptionUserInfo = NSEntityDescription.entity(forEntityName: String.init(describing: UserInfo.self), in: context)
    }
    
    override func tearDown() {
        try? super.tearDownWithError()
        persistentContainer = nil
        context = nil
        entityDescription = nil
        apiMock = nil
    }
    
    // MARK: - Test cases
    
    func testUserCreateWithMockApi() throws {
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
                    case let .success(user):
                        let user = User(from: githubUser,
                                        and: user,
                                        moc: self.context,
                                        userEntity: self.entityDescription, userInfoEntity: self.entityDescriptionUserInfo)
                        do {
                            try self.context.save()
                        } catch {
                            let nserror = error as NSError
                            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                        }
                        XCTAssertNotNil(user)
                        XCTAssert(user.id == 1)
                        XCTAssert(user.login == "mojombo")
                        XCTAssert(user.nodeId == "MDQ6VXNlcjE=")
                        do {
                            if let user = try self.fetchUserUsing(id: 1000000, context: self.context) {
                                XCTAssert(user.id == 1)
                                XCTAssert(user.login == "mojombo")
                                XCTAssert(user.nodeId == "MDQ6VXNlcjE")
                                XCTAssert(user.userInfo!.name == "Tom Preston-Werner")
                            }
                        } catch {
                            fatalError(error.localizedDescription)
                        }
                    case let .failure(error):
                        fatalError(error.localizedDescription)
                    }
                }
            }
        }
    }
}

