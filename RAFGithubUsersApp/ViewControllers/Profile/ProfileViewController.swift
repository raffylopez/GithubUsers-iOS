//
//  ViewController.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit
import SkeletonView

class ProfileViewController: UIViewController {
    @IBOutlet var boxBlue: UIView!
    var viewModel: ProfileViewModel!
    private func setupLayout() {
        boxBlue.showAnimatedGradientSkeleton()
        boxBlue.layer.borderWidth = 3.0
        boxBlue.layer.masksToBounds = false
        boxBlue.layer.borderColor = UIColor.white.cgColor
        boxBlue.layer.cornerRadius = boxBlue.frame.size.width / 2
        boxBlue.clipsToBounds = true
    }
    
    private func setupNavbar() {
        self.title = "User Profile"
        self.navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func loadView() {
        super.loadView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.systemBackground
        setupNavbar()
        setupLayout()
    }


}

