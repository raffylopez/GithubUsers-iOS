//
//  VcType.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

enum VcType {
    case usersList(UsersViewModel)
    case userProfile(ProfileViewModel)
}

// MARK: - ViewControllers
class StoryBoard {
    static var main: UIStoryboard = {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        return storyboard
    }()
}

/**
 Factory class for convenietly instancing and assembling view controller classes
 */
class ViewControllersFactory {
    public static func instance(vcType: VcType) -> UIViewController {
        switch vcType {
        case let .usersList(viewModel):
            let controller = UsersViewController(viewModel: viewModel)
            return controller
        case let .userProfile(viewModel):
            let controller = StoryBoard.main.instantiateViewController(identifier: String(describing: ProfileViewController.self)) as! ProfileViewController
            controller.viewModel = viewModel
            return controller
        }
    }
}
