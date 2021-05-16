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
    func translate(from apiUser: GithubUser, with userInfo: UserInfo) -> User
    func getUsers(callback: @escaping (Result<[User], Error>) -> Void)
    func getUser(id: Int) -> User?
    func saveAll() throws
    func deleteAll() throws
}

extension CoreDataService: UsersProvider {

    func getUser(id: Int) -> User? {
        let entityName = String(describing: User.self)
        let fetchRequest: NSFetchRequest<User> = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate( format: "\(#keyPath(User.id)) == \(id)" )
        fetchRequest.predicate = predicate
        var fetchedUserInfo: [User]!
        context.performAndWait {
            fetchedUserInfo = try? fetchRequest.execute()
        }
        if let existingInfo = fetchedUserInfo?.first {
            return existingInfo
        }
        return nil


    }
    func translate(from apiUser: GithubUser) -> User {
        var managedUser: User!
        context.performAndWait {
            managedUser = User(from: apiUser, moc: context)
        }
        return managedUser
    }
    
    func translate(from apiUser: GithubUser, with userInfo: UserInfo) -> User {
        var managedUser: User!
        context.performAndWait {
            managedUser = User(from: apiUser, with: userInfo, moc: context)
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
//        if context.hasChanges {
            try saveContext()
//        }
    }
}
