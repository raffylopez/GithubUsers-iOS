//
//  ProfileViewDelegate.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate: class, ViewModelDelegate {
    func didSaveNote(at indexPath: IndexPath)
    func didSeeProfile(at indexPath: IndexPath)
}
