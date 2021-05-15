//
//  ImageStore.swift
//  LootLogger2
//
//  Created by Volare on 2/28/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import CoreData

protocol UsersProvider {
    func translate(from apiUser: GithubUser) -> User
    func getUsers(callback: @escaping (Result<[User], Error>) -> Void)
    func saveAll() throws
    func deleteAll() throws
}

extension CoreDataService: UsersProvider {

    func translate(from apiUser: GithubUser) -> User {
        var managedUser: User!
        context.performAndWait {
            managedUser = User(from: apiUser, moc: context)
        }
        return managedUser
    }
    
    func deleteAll() throws {
        let entityName = String(describing: User.self)
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let coordinator = Self.persistentContainer.persistentStoreCoordinator
        try coordinator.execute(deleteRequest, with: context)
    }

    func getUsers(callback: @escaping (Result<[User], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        context.perform {
            do {
                var allUsers: [User]!
                allUsers = try self.context.fetch(fetchRequest)
                callback(.success(allUsers))
            } catch {
                callback(.failure(error))
            }
        }
    }
    
    func saveAll() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
