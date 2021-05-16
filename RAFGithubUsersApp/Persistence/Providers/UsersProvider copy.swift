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
    func getUserInfo(callback: @escaping (Result<UserInfo, Error>) -> Void)
    func save() throws
    func delete() throws
}

extension CoreDataService: UserInfoProvider {

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

    func getUserInfo(callback: @escaping (Result<UserInfo, Error>) -> Void) {
        let fetchRequest: NSFetchRequest<UserInfo> = UserInfo.fetchRequest()
        context.perform {
            do {
                var userInfo: UserInfo!
                userInfo = try self.context.fetch(fetchRequest).first
                // TODO : no result
                callback(.success(userInfo))
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
