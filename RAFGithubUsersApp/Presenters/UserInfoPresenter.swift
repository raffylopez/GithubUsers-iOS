//
//  AmiiboElementsViewModel.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/17/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class UserInfoPresenter {
    let userInfo: UserInfo!
    
    init(_ userInfo: UserInfo) {
        self.userInfo = userInfo
    }

    var name: String { return self.userInfo.name ?? "" }
    var login: String { return self.userInfo.login ?? "-" }
    var bio: String { return self.userInfo.bio ?? "" }
    var followers: String { return "\(self.userInfo.followers)" }
    var following: String { return "\(self.userInfo.following)" }
    var company: String { return self.userInfo.company ?? "-" }
    var blog: String {
        guard let blog = self.userInfo.blog, !blog.isEmpty else { return "-" }
        return blog
    }
    var location: String { return self.userInfo.location ?? "-" }
    var email: String { return self.userInfo.email ?? "-" }
    var hireability: String { return self.userInfo.isHireable ? "Yes" : "No"  }

}
