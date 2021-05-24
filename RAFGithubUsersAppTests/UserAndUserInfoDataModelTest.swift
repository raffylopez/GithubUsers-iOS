//
//  UserDataModelTest.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
import CoreData
@testable import GithubApp

class UserAndUserInfoDataModelTest: XCTestCase {
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var userEntity: NSEntityDescription!
    var userInfoEntity: NSEntityDescription!
    
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
        userEntity = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: persistentContainer.viewContext)
        userInfoEntity = NSEntityDescription.entity(forEntityName: String.init(describing: UserInfo.self), in: persistentContainer.viewContext)
    }
    
    override func tearDown() {
        try? super.tearDownWithError()
        persistentContainer = nil
        context = nil
        userEntity = nil
        userInfoEntity = nil
    }
    
    // MARK: - Test cases
    func testCreate() throws {
        let userInfo = UserInfo(entity: userInfoEntity!, insertInto: context)
        context.performAndWait {
            userInfo.name = "test_create_name"
            userInfo.email = "test_create@email.com"
        }

        let user = User(entity: userEntity!, insertInto: context)
        context.performAndWait {
            user.id = 1000000
            user.login = "test_create"
            user.userInfo = userInfo
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        XCTAssertNotNil(user)
        XCTAssertNotNil(userInfo)
        XCTAssert(user.id == 1000000)
        XCTAssert(user.login == "test_create")
        
        guard let userInfoNN = user.userInfo else { XCTFail(); return }
        XCTAssert(userInfoNN.email == "test_create@email.com")
        XCTAssert(userInfoNN.name == "test_create_name")
    }
    
    func testFetch() throws {
        let userInfo = UserInfo(entity: userInfoEntity!, insertInto: context)
        context.performAndWait {
            userInfo.name = "test_fetch_name"
            userInfo.email = "test_fetch@email.com"
        }
        
        let user = User(entity: userEntity!, insertInto: context)
        context.performAndWait {
            user.id = 1000000
            user.login = "test_fetch"
            user.userInfo = userInfo
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        guard let userInfoNN = user.userInfo else { XCTFail(); return }
        guard let userNN = try fetchUserUsing(id: 1000000, context: context) else { XCTFail(); return }
        XCTAssert(userNN.id == 1000000)
        XCTAssert(userNN.login == "test_fetch")
        XCTAssert(userInfoNN.email == "test_fetch@email.com")
        XCTAssert(userInfoNN.name == "test_fetch_name")
    }
    
    func testUpdate() throws {
        let userInfo = UserInfo(entity: userInfoEntity!, insertInto: context)
        context.performAndWait {
            userInfo.name = "test_fetch_name"
            userInfo.email = "test_fetch@email.com"
        }
        
        let user = User(entity: userEntity!, insertInto: context)
        context.performAndWait {
            user.id = 1000000
            user.login = "test_fetch"
            user.userInfo = userInfo
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        guard let userInfoNN = user.userInfo else { XCTFail(); return }
        guard let userNN = try fetchUserUsing(id: 1000000, context: context) else { XCTFail(); return }
        XCTAssert(userNN.id == 1000000)
        XCTAssert(userNN.login == "test_fetch")
        XCTAssert(userInfoNN.email == "test_fetch@email.com")
        XCTAssert(userInfoNN.name == "test_fetch_name")
        
        if let userForUpdate = try? fetchUserUsing(id: 1000000, context: context), let userInfo = userForUpdate.userInfo {
            context.performAndWait {
                userForUpdate.id = 1000000
                userForUpdate.login = "test_update"
                userInfo.name = "test_userinfo_update"
                userInfo.followers = 200
            }
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }

        if let fetchedUser = try? fetchUserUsing(id: 1000000, context: context), let fetchUserInfo = fetchedUser.userInfo {
            XCTAssert(fetchedUser.id == 1000000)
            XCTAssert(fetchedUser.login == "test_update")
            XCTAssert(fetchUserInfo.name == "test_userinfo_update")
            XCTAssert(fetchUserInfo.followers == 200)
            return
        }
        XCTFail()
    }

}
