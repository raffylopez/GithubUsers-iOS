//
//  UserDataModelTest.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
import CoreData
@testable import GithubApp

class UserDataModelTest: XCTestCase {
    var persistentContainer: NSPersistentContainer!
    var context: NSManagedObjectContext!
    var entityDescription: NSEntityDescription!
    
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
        entityDescription = NSEntityDescription.entity(forEntityName: String.init(describing: User.self), in: persistentContainer.viewContext)
    }
    
    override func tearDown() {
        try? super.tearDownWithError()
        persistentContainer = nil
        context = nil
        entityDescription = nil
    }
    
    // MARK: - Test cases
    func testCreate() throws {
        let user = User(entity: entityDescription!, insertInto: context)
        context.performAndWait {
            user.id = 1000000
            user.login = "test_create"
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
        XCTAssert(user.id == 1000000)
        XCTAssert(user.login == "test_create")
    }
    
    func testFetch() throws {
        let user = User(entity: entityDescription!, insertInto: context)
        context.performAndWait {
            user.id = 1000000
            user.login = "test_fetch"
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
        XCTAssert(user.id == 1000000)
        XCTAssert(user.login == "test_fetch")
        if let user = try fetchUserUsing(id: 1000000, context: context) {
            XCTAssert(user.id == 1000000)
            XCTAssert(user.login == "test_fetch")
        }
    }
    
    func testUpdate() throws {
        let userForUpdate = User(entity: entityDescription!, insertInto: context)
        context.performAndWait {
            userForUpdate.id = 1000000
            userForUpdate.login = "test_update"
        }
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        if let userForUpdate = try? fetchUserUsing(id: 1000000, context: context) {
            context.performAndWait {
                userForUpdate.id = 1000000
                userForUpdate.login = "test_update"
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
        
        let user = try fetchUserUsing(id:1000000, context: context)
        XCTAssertNotNil(user)
        
        if let user = user {
            XCTAssert(user.id == 1000000)
            XCTAssert(user.login == "test_update")
        }
        
    }
    
}
