//
//  ImageStore.swift
//  LootLogger2
//
//  Created by Volare on 2/28/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import CoreData

protocol UserInfoProvider {
    func translate(from apiUser: GithubUserInfo) -> UserInfo
    func getAllUserInfo(callback: @escaping (Result<[UserInfo], Error>) -> Void)
    func getUserInfo(with id: Int) -> UserInfo?
    func save() throws
    func delete() throws
}

extension CoreDataService: UserInfoProvider {

    func getUserInfo(with id: Int) -> UserInfo? {
        let entityName = String(describing: UserInfo.self)
        let fetchRequest: NSFetchRequest<UserInfo> = NSFetchRequest(entityName: entityName)
        let predicate = NSPredicate( format: "\(#keyPath(UserInfo.id)) == \(id)" )
        fetchRequest.predicate = predicate
        var fetchedUserInfo: [UserInfo]!
        context.performAndWait {
            fetchedUserInfo = try? fetchRequest.execute()
        }
        if let existingInfo = fetchedUserInfo?.first {
            return existingInfo
        }
        
        return nil
        
    }
    
    func translate(from apiUser: GithubUserInfo) -> UserInfo {
        var managedUserInfo: UserInfo!
        context.performAndWait {
            managedUserInfo = UserInfo(from: apiUser, moc: context)
        }
        return managedUserInfo
    }

    func delete() throws {
        let entityName = String(describing: UserInfo.self)
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        let coordinator = Self.persistentContainer.persistentStoreCoordinator
        try coordinator.execute(deleteRequest, with: context)
    }

    func getAllUserInfo(callback: @escaping (Result<[UserInfo], Error>) -> Void) {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        context.perform {
            do {
                var userInfos: [UserInfo]!
                userInfos = try self.context.fetch(fetchRequest)
                // TODO : no result
                callback(.success(userInfos))
            } catch {
                callback(.failure(error))
            }
        }
    }
    
    func save() throws {
        if context.hasChanges {
            try context.save()
        }
    }
}
