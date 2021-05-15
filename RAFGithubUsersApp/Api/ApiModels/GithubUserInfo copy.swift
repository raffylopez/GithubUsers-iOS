//
//  GithubUser.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.

import Foundation

// MARK: - GithubUserInfo
struct GithubUserInfo: Codable {
    let login: String
    let id: Int
    let nodeID: String
    let avatarURL: String
    let gravatarID: String
    let url, htmlURL, followersURL: String
    let followingURL, gistsURL, starredURL: String
    let subscriptionsURL, organizationsURL, reposURL: String
    let eventsURL: String
    let receivedEventsURL: String
    let type: String
    let siteAdmin: Bool
    let name, company: String
    let blog: String
    let location, email, hireable, bio: String
    let twitterUsername: String
    let publicRepos, publicGists, followers, following: Int
    let createdAt, updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case login, id
        case nodeID = "node_id"
        case avatarURL = "avatar_url"
        case gravatarID = "gravatar_id"
        case url
        case htmlURL = "html_url"
        case followersURL = "followers_url"
        case followingURL = "following_url"
        case gistsURL = "gists_url"
        case starredURL = "starred_url"
        case subscriptionsURL = "subscriptions_url"
        case organizationsURL = "organizations_url"
        case reposURL = "repos_url"
        case eventsURL = "events_url"
        case receivedEventsURL = "received_events_url"
        case type
        case siteAdmin = "site_admin"
        case name, company, blog, location, email, hireable, bio
        case twitterUsername = "twitter_username"
        case publicRepos = "public_repos"
        case publicGists = "public_gists"
        case followers, following
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: GithubUserInfo convenience initializers and mutators

extension GithubUserInfo {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(GithubUserInfo.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        login: String? = nil,
        id: Int? = nil,
        nodeID: String? = nil,
        avatarURL: String? = nil,
        gravatarID: String? = nil,
        url: String? = nil,
        htmlURL: String? = nil,
        followersURL: String? = nil,
        followingURL: String? = nil,
        gistsURL: String? = nil,
        starredURL: String? = nil,
        subscriptionsURL: String? = nil,
        organizationsURL: String? = nil,
        reposURL: String? = nil,
        eventsURL: String? = nil,
        receivedEventsURL: String? = nil,
        type: String? = nil,
        siteAdmin: Bool? = nil,
        name: String? = nil,
        company: String? = nil,
        blog: String? = nil,
        location: String? = nil,
        email: String? = nil,
        hireable: String? = nil,
        bio: String? = nil,
        twitterUsername: String? = nil,
        publicRepos: Int? = nil,
        publicGists: Int? = nil,
        followers: Int? = nil,
        following: Int? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) -> GithubUserInfo {
        return GithubUserInfo(
            login: login ?? self.login,
            id: id ?? self.id,
            nodeID: nodeID ?? self.nodeID,
            avatarURL: avatarURL ?? self.avatarURL,
            gravatarID: gravatarID ?? self.gravatarID,
            url: url ?? self.url,
            htmlURL: htmlURL ?? self.htmlURL,
            followersURL: followersURL ?? self.followersURL,
            followingURL: followingURL ?? self.followingURL,
            gistsURL: gistsURL ?? self.gistsURL,
            starredURL: starredURL ?? self.starredURL,
            subscriptionsURL: subscriptionsURL ?? self.subscriptionsURL,
            organizationsURL: organizationsURL ?? self.organizationsURL,
            reposURL: reposURL ?? self.reposURL,
            eventsURL: eventsURL ?? self.eventsURL,
            receivedEventsURL: receivedEventsURL ?? self.receivedEventsURL,
            type: type ?? self.type,
            siteAdmin: siteAdmin ?? self.siteAdmin,
            name: name ?? self.name,
            company: company ?? self.company,
            blog: blog ?? self.blog,
            location: location ?? self.location,
            email: email ?? self.email,
            hireable: hireable ?? self.hireable,
            bio: bio ?? self.bio,
            twitterUsername: twitterUsername ?? self.twitterUsername,
            publicRepos: publicRepos ?? self.publicRepos,
            publicGists: publicGists ?? self.publicGists,
            followers: followers ?? self.followers,
            following: following ?? self.following,
            createdAt: createdAt ?? self.createdAt,
            updatedAt: updatedAt ?? self.updatedAt
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: - URLSession response handlers

extension URLSession {
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            do {
            completionHandler(try newJSONDecoder().decode(T.self, from: data), response, nil)
            } catch {
                preconditionFailure(error.localizedDescription)
                completionHandler(nil, nil, error)
            }
        }
    }

    func githubUserInfoTask(with url: URL, completionHandler: @escaping (GithubUserInfo?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return self.codableTask(with: url, completionHandler: completionHandler)
    }
}

