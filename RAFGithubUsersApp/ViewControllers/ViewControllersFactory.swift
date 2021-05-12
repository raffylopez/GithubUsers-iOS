//
//  ViewControllers.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

enum VcType {
    case usersList(UsersViewModel)
    case userProfile
}

// MARK: - ViewControllers
class ViewControllersFactory {
    public static func instance(vcType: VcType) -> UIViewController {
        switch vcType {
        case let .usersList(viewModel):
            let controller = UsersListViewController()
            controller.viewModel = viewModel
            return controller
        case .userProfile:
            return UserProfileViewController()
        }
    }
}
