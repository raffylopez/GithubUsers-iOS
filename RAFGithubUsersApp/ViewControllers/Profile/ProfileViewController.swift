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
    
    @IBOutlet var lblName: UILabel!
    
    @IBOutlet var lblLogin: UILabel!
    
    @IBOutlet var lblFollow: UILabel!
    
    @IBOutlet var lblBio: UILabel!
    var viewModel: ProfileViewModel!
    private func setupLayout() {
        boxBlue.showAnimatedGradientSkeleton()
        boxBlue.layer.borderWidth = 3.0
        boxBlue.layer.masksToBounds = false
        boxBlue.layer.borderColor = UIColor.white.cgColor
        boxBlue.layer.cornerRadius = boxBlue.frame.size.width / 2
        boxBlue.clipsToBounds = true
        
        lblName.isSkeletonable = true
        lblName.isHiddenWhenSkeletonIsActive = false
        lblName.skeletonCornerRadius = 2.0
        lblName.numberOfLines = 0
        lblName.sizeToFit()
        self.lblName.skeletonPaddingInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.lblName.frame.height, right: self.lblName.frame.width)
        self.lblName.showAnimatedGradientSkeleton()
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000)) {
            self.lblName.hideSkeleton()
        }
//        lblLogin.showAnimatedGradientSkeleton()
//        lblFollow.showAnimatedGradientSkeleton()
//        lblBio.showAnimatedGradientSkeleton()
    }
    
    private func setupNavbar() {
        navigationItem.title = "Profile"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationItem.largeTitleDisplayMode = .never
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.navigationController?.navigationBar.prefersLargeTitles = false
    }

}

