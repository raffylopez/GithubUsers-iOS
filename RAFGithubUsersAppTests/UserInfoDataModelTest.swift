//
//  UserDataModelTest.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
import CoreData
@testable import GithubApp

class UserInfoDataModelTest: XCTestCase {
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var entityDescription: NSEntityDescription!
    
    private func saveContext () {
    }
    
    // MARK: - Utility methods
    private func fetchUserInfoUsing(name: String, context: NSManagedObjectContext) throws -> UserInfo?  {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(UserInfo.name)) == %@", name)
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
        entityDescription = NSEntityDescription.entity(forEntityName: String.init(describing: UserInfo.self), in: persistentContainer.viewContext)
    }
    
    override func tearDown() {
        try? super.tearDownWithError()
        persistentContainer = nil
        context = nil
        entityDescription = nil
    }
    
    // MARK: - Test cases
    func testCreate() throws {
        let userInfo = UserInfo(entity: entityDescription!, insertInto: context)
        context.performAndWait {
            userInfo.name = "test_create"
            userInfo.followers = 200
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        XCTAssert(userInfo.name == "test_create")
        XCTAssert(userInfo.followers == 200)
    }
    
    func testFetch() throws {
        let userInfo = UserInfo(entity: entityDescription!, insertInto: context)
        context.performAndWait {
            userInfo.name = "test_fetch"
            userInfo.followers = 1000
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
        if let userInfo = try fetchUserInfoUsing(name: "test_fetch", context: context) {
            XCTAssert(userInfo.name == "test_fetch")
            XCTAssert(userInfo.followers == 1000)
        }
    }
    
    func testUpdate() throws {
        let userInfo = UserInfo(entity: entityDescription!, insertInto: context)
        context.performAndWait {
            userInfo.name = "test_update"
            userInfo.followers = 550
        }
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        if let userInfoForUpdate = try fetchUserInfoUsing(name: "test_update", context: context) {
            context.performAndWait {
                userInfoForUpdate.name = "test_update"
                userInfoForUpdate.followers = 550
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
        
        if let userInfo = try fetchUserInfoUsing(name: "test_update", context: context) {
            XCTAssert(userInfo.followers == 550)
            XCTAssert(userInfo.name == "test_update")
        }
    }
    
}
