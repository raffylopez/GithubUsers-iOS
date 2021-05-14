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
public class UserInfo: User {
    lazy var presented: UserInfoPresenter = {
        return UserInfoPresenter(self)
    }()
}

