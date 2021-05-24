//
//  UserPresenter.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class UserPresenter {
    let user: User!
    
    init(_ user: User) {
        self.user = user
    }

    var login: String {
        return self.user.login ?? ""
    }
    
    var urlHtml: String {
        return self.user.urlHtml ?? ""
    }
}
