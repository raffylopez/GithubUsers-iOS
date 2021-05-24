//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import CoreData

/**
 Don't remove this file when regenerating the User entity class.
 Overwrite the DataProperties file instead. This class is for maintaining
 methods and initializers.
 */
@objc(User)
public class User: NSManagedObject {
    func present() -> UserPresenter {
        return UserPresenter(self)
    }
    
    convenience init(from githubUser: GithubUser,
                     and info: GithubUserInfo,
                     moc: NSManagedObjectContext,
                     userEntity: NSEntityDescription, userInfoEntity: NSEntityDescription) {
        self.init(entity: userEntity, insertInto: moc)
        
        self.login = githubUser.login
        self.id = Int64(githubUser.id)
        self.nodeId = githubUser.nodeID
        self.urlAvatar = githubUser.avatarURL
        self.gravatarId = githubUser.gravatarID
        self.url = githubUser.url
        self.urlHtml = githubUser.htmlURL
        self.urlFollowers = githubUser.followersURL
        self.urlFollowing = githubUser.followingURL
        self.urlGists = githubUser.gistsURL
        self.urlStarred = githubUser.starredURL
        self.urlSubscriptions = githubUser.subscriptionsURL
        self.urlOrganizations = githubUser.organizationsURL
        self.urlRepos = githubUser.reposURL
        self.urlEvents = githubUser.eventsURL
        self.urlReceivedEvents = githubUser.receivedEventsURL
        self.userType = githubUser.type
        self.isSiteAdmin = githubUser.siteAdmin
        self.userInfo = UserInfo(from: info, entity: userInfoEntity, moc: moc)
    }
    
    convenience init(from githubUser: GithubUser, moc: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: String.init(describing: Self.self), in: moc)
        self.init(entity: entity!, insertInto: moc)
        
        self.login = githubUser.login
        self.id = Int64(githubUser.id)
        self.nodeId = githubUser.nodeID
        self.urlAvatar = githubUser.avatarURL
        self.gravatarId = githubUser.gravatarID
        self.url = githubUser.url
        self.urlHtml = githubUser.htmlURL
        self.urlFollowers = githubUser.followersURL
        self.urlFollowing = githubUser.followingURL
        self.urlGists = githubUser.gistsURL
        self.urlStarred = githubUser.starredURL
        self.urlSubscriptions = githubUser.subscriptionsURL
        self.urlOrganizations = githubUser.organizationsURL
        self.urlRepos = githubUser.reposURL
        self.urlEvents = githubUser.eventsURL
        self.urlReceivedEvents = githubUser.receivedEventsURL
        self.userType = githubUser.type
        self.isSiteAdmin = githubUser.siteAdmin
        self.userInfo = UserInfo(context: moc)
    }
    
    convenience init(from githubUser: GithubUser, with userInfo: UserInfo, moc: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: String.init(describing: Self.self), in: moc)
        self.init(entity: entity!, insertInto: moc)
        
        self.login = githubUser.login
        self.id = Int64(githubUser.id)
        self.nodeId = githubUser.nodeID
        self.urlAvatar = githubUser.avatarURL
        self.gravatarId = githubUser.gravatarID
        self.url = githubUser.url
        self.urlHtml = githubUser.htmlURL
        self.urlFollowers = githubUser.followersURL
        self.urlFollowing = githubUser.followingURL
        self.urlGists = githubUser.gistsURL
        self.urlStarred = githubUser.starredURL
        self.urlSubscriptions = githubUser.subscriptionsURL
        self.urlOrganizations = githubUser.organizationsURL
        self.urlRepos = githubUser.reposURL
        self.urlEvents = githubUser.eventsURL
        self.urlReceivedEvents = githubUser.receivedEventsURL
        self.userType = githubUser.type
        self.isSiteAdmin = githubUser.siteAdmin
        self.userInfo = userInfo
    }
    
    func merge(with githubUser: GithubUser, moc: NSManagedObjectContext) {
        self.login = githubUser.login
        self.id = Int64(githubUser.id)
        self.nodeId = githubUser.nodeID
        self.urlAvatar = githubUser.avatarURL
        self.gravatarId = githubUser.gravatarID
        self.url = githubUser.url
        self.urlHtml = githubUser.htmlURL
        self.urlFollowers = githubUser.followersURL
        self.urlFollowing = githubUser.followingURL
        self.urlGists = githubUser.gistsURL
        self.urlStarred = githubUser.starredURL
        self.urlSubscriptions = githubUser.subscriptionsURL
        self.urlOrganizations = githubUser.organizationsURL
        self.urlRepos = githubUser.reposURL
        self.urlEvents = githubUser.eventsURL
        self.urlReceivedEvents = githubUser.receivedEventsURL
        self.userType = githubUser.type
        self.isSiteAdmin = githubUser.siteAdmin
    }
}
