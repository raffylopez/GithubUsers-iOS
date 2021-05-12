//
//  AmiiboElementsViewModel.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/17/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

// MARK: - AmiiboElementPresenter
class UserPresenter {
    let user: User!
    
    init(_ user: User) {
        self.user = user
    }

    var login: String {
        return "Login".localized() + ": " + (self.user.userInfo?.name ?? "")
    }
}
