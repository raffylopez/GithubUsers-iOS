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
        return self.user.login ?? ""
    }
    
    var urlHtml: String {
        return self.user.urlHtml ?? ""
    }
}
