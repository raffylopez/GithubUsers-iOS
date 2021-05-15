//
//  UserInfo+CoreDataProperties.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/12/21.
//  Copyright © 2021 Raf. All rights reserved.
//
//

import Foundation
import CoreData


extension UserInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<UserInfo> {
        return NSFetchRequest<UserInfo>(entityName: "UserInfo")
    }

    @NSManaged public var bio: String?
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

}
