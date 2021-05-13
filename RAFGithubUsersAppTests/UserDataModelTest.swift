//
//  RAFGithubUsersAppTests.swift
//  RAFGithubUsersAppTests
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import XCTest
import CoreData
@testable import GithubApp

class UserDataModelTest: XCTestCase {
    
    // MARK: - Core Data stack
    
    private static let persistentContainerName = "RAFGithubUsersApp"
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Self.persistentContainerName )
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    private func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Utility methods
    private func fetchUserUsing(id: Int32) throws -> User?  {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let predicate = NSPredicate(format: "\(#keyPath(User.id)) == 111")
        fetchRequest.predicate = predicate
        let result = try? persistentContainer.viewContext.fetch(fetchRequest)
        return result?.first
    }
    
    override func setUpWithError() throws {
    }
    
    override func tearDownWithError() throws {
    }
    
    // MARK: - Test cases
    func testCreate() throws {
        let user = User(context: persistentContainer.viewContext)
        persistentContainer.viewContext.performAndWait {
            user.id = 111
            user.login = "test"
        }
    }
    
    func testFetch() throws {
        if let user = try? fetchUserUsing(id: 111) {
            XCTAssert(user.id == 111)
            XCTAssert(user.login == "test")
        }
    }
    
    func testUpdate() throws {
        if let userForUpdate = try? fetchUserUsing(id: 111) {
            persistentContainer.viewContext.performAndWait {
                userForUpdate.id = 111
                userForUpdate.login = "test"
            }
        }
        
        if let user = try? fetchUserUsing(id: 111) {
            XCTAssert(user.id == 111)
            XCTAssert(user.login == "test")
        }
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
