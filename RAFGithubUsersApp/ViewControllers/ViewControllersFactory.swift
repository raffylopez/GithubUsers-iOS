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
    case userProfile(ProfileViewModel)
}

// MARK: - ViewControllers
class StoryBoard {
    static var main: UIStoryboard = {
        let storyboard = UIStoryboard(name:"Main", bundle: nil)
        return storyboard
    }()
}

class ViewControllersFactory {
    public static func instance(vcType: VcType) -> UIViewController {
        switch vcType {
        case let .usersList(viewModel):
            let controller = UsersViewController()
            controller.viewModel = viewModel
            return controller
        case let .userProfile(viewModel):
            let controller = StoryBoard.main.instantiateViewController(identifier: String(describing: ProfileViewController.self)) as! ProfileViewController
            controller.viewModel = viewModel
            return controller
        }
    }
}
