//
//  User+CoreDataProperties.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/12/21.
//  Copyright © 2021 Raf. All rights reserved.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var login: String?
    @NSManaged public var id: Int32
    @NSManaged public var nodeId: String?
    @NSManaged public var urlAvatar: String?
    @NSManaged public var gravatarId: String?
    @NSManaged public var url: String?
    @NSManaged public var blog: String?
    @NSManaged public var urlHtml: String?
    @NSManaged public var urlFollowers: String?
    @NSManaged public var urlFollowing: String?
    @NSManaged public var urlGists: String?
    @NSManaged public var urlStarred: String?
    @NSManaged public var urlSubscriptions: String?
    @NSManaged public var urlOrganizations: String?
    @NSManaged public var urlRepos: String?
    @NSManaged public var urlEvents: String?
    @NSManaged public var urlReceivedEvents: String?
    @NSManaged public var userType: String?
    @NSManaged public var isSiteAdmin: Bool
    @NSManaged public var userInfo: UserInfo?

}
