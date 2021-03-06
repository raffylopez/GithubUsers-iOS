//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import CoreData

/**
 Autogenerated NSManagedObject class. Safe to regenerate.
 */
extension UserInfo {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }
    
    @NSManaged public var bio: String?
    @NSManaged public var blog: String?
    @NSManaged public var company: String?
    @NSManaged public var createdAt: Date?
    @NSManaged public var email: String?
    @NSManaged public var followers: Int32
    @NSManaged public var following: Int32
    @NSManaged public var isHireable: Bool
    @NSManaged public var location: String?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var publicGists: Int32
    @NSManaged public var publicRepos: Int32
    @NSManaged public var seen: Bool
    @NSManaged public var twitterUsername: String?
    @NSManaged public var updatedAt: Date?
    @NSManaged public var user: User?
    
}
