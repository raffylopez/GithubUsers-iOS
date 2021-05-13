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
    @IBOutlet var imgAvatar: UIImageView!
    let label = UILabel()
    override func loadView() {
        super.loadView()
        label.text = "Foobar"
        label.center = self.view.center
        label.sizeToFit()
        self.view.addSubview(label)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        boxBlue.showAnimatedGradientSkeleton()
        imgAvatar.showAnimatedGradientSkeleton()
        self.view.backgroundColor = UIColor.systemBackground
    }


}

