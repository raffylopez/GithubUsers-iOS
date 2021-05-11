//
//  ViewControllers.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

enum VcType {
    case usersList
    case userProfile
}

// MARK: - ViewControllers
class ViewControllersFactory {
    public static func instance(vcType: VcType) -> UIViewController {
        switch vcType {
        case .usersList:
            return UsersListViewController()
        case .userProfile:
            return UserProfileViewController()
        }
    }
}
