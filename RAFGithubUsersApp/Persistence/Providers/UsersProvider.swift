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
    func getUsers(limit: Int?, callback: @escaping (Result<[User], Error>) -> Void)
    func getUserCount() -> Int
    func getUser(id: Int) -> User?
    func saveAll() throws
    func deleteAll() throws
    func filterUsers(with term: String, callback: @escaping (Result<[User], Error>) -> Void)
}

extension CoreDataService: UsersProvider {

    func getUserCount() -> Int {
        let entityName = String(describing: User.self)
        let fetchRequest: NSFetchRequest<User> = NSFetchRequest(entityName: entityName)
        fetchRequest.includesSubentities = false
        
        var count: Int! = -1
        context.performAndWait {
            do {
                try count = context.count(for: fetchRequest)
            } catch {
                count = -1
            }
        }
        return count
    }

    func filterUsers(with term: String, callback: @escaping (Result<[User], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(User.id), ascending: true)
        let searchPredicate = NSPredicate(format: "\(#keyPath(User.login)) CONTAINS[c] %@", term)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = searchPredicate
        
//        let searchPredicate = NSPredicate(format: "SELF.login CONTAINS[c] %@", term)
        context.perform {
            do {
                var filteredUsers: [User]!
                filteredUsers = try self.context.fetch(fetchRequest)
                callback(.success(filteredUsers))
            } catch {
                callback(.failure(error))
            }
        }
    }
    

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

    /* Gets all users. May include duplicates. */
    func getUsers(callback: @escaping (Result<[User], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(User.id), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
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
    
    /* Get n users. If limit is nil, fetch all */
    func getUsers(limit: Int? = nil, callback: @escaping (Result<[User], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: #keyPath(User.id), ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        if let limit = limit {
            fetchRequest.fetchLimit = limit
        }
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
