//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import CoreData

/* UserInfo service/data access object class */
protocol UserInfoProvider {
    func translate(from apiUser: GithubUserInfo) -> UserInfo
    func getAllUserInfo(callback: @escaping (Result<[UserInfo], Error>) -> Void)
    func getUserInfo(with id: Int) -> UserInfo?
    func getUserInfo(for user: User) -> UserInfo?
    func save() throws
    func delete() throws
}

extension CoreDataService: UserInfoProvider {
    func getUserInfo(for user: User) -> UserInfo? {
        let entityName = String(describing: UserInfo.self)
        let fetchRequest: NSFetchRequest<UserInfo> = NSFetchRequest(entityName: entityName)
        let format = "\(#keyPath(UserInfo.user)) == \(user)"
        let predicate = NSPredicate( format: format )
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
    
    func getUserInfo(with id: Int) -> UserInfo? {
        let entityName = String(describing: UserInfo.self)
        let fetchRequest: NSFetchRequest<UserInfo> = NSFetchRequest(entityName: entityName)
        
        let predicate = NSPredicate( format: "\(#keyPath(UserInfo.user.id)) == \(id)" )
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
            try saveContext()
        }
    }
}
