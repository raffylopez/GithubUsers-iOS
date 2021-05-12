//
//  ViewController.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController {
    let label = UILabel()
    override func loadView() {
        super.loadView()
        self.view.backgroundColor = UIColor.systemBackground
        label.text = "Foobar"
        label.center = self.view.center
        label.sizeToFit()
        self.view.addSubview(label)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

