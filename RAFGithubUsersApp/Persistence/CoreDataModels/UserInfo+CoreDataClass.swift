//
//  UserInfo+CoreDataClass.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/12/21.
//  Copyright © 2021 Raf. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UserInfo)
public class UserInfo: NSManagedObject {
    lazy var presented: UserInfoPresenter = {
        return UserInfoPresenter(self)
    }()
    
    convenience init(from: GithubUserInfo, moc: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: String.init(describing: Self.self), in: moc)
        self.init(entity: entity!, insertInto: moc)
        moc.performAndWait {
            self.bio = from.bio
            self.blog = from.blog
            self.company = from.company
            self.createdAt = from.createdAt
            self.email = from.email
            self.followers = Int32(from.followers ?? 0)
            self.following = Int32(from.following ?? 0)
            self.isHireable = from.hireable ?? false
            self.location = from.location
            self.name = from.name
            self.publicGists = Int32(from.publicGists ?? 0)
            self.publicRepos = Int32(from.publicRepos ?? 0)
            self.twitterUsername = from.twitterUsername
            self.updatedAt = from.updatedAt
        }
        try? moc.save()
    }
    
    func set(from: GithubUserInfo, moc: NSManagedObjectContext) {
        moc.performAndWait {
            self.bio = from.bio
            self.blog = from.blog
            self.company = from.company
            self.createdAt = from.createdAt
            self.email = from.email
            self.followers = Int32(from.followers ?? 0)
            self.following = Int32(from.following ?? 0)
            self.isHireable = from.hireable ?? false
            self.location = from.location
            self.name = from.name
            self.publicGists = Int32(from.publicGists ?? 0)
            self.publicRepos = Int32(from.publicRepos ?? 0)
            self.twitterUsername = from.twitterUsername
            self.updatedAt = from.updatedAt
        }
        try? moc.save()
    }

    convenience init(moc: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: String.init(describing: Self.self), in: moc)
        self.init(entity: entity!, insertInto: moc)
    }
}

