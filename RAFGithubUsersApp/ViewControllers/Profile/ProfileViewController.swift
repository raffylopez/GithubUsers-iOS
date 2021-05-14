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
    @IBOutlet var lblBio: UILabel!
    @IBOutlet var lblFollow: UILabel!
    @IBOutlet var lblCompany: UILabel!
    @IBOutlet var lblBlog: UILabel!
    @IBOutlet var lblLocation: UILabel!
    @IBOutlet var lblEmail: UILabel!
    @IBOutlet var lblHireability: UILabel!

    @IBOutlet var lblCompanyTag: UILabel!
    @IBOutlet var lblBlogTag: UILabel!
    @IBOutlet var lblLocationTag: UILabel!
    @IBOutlet var lblEmailTag: UILabel!
    @IBOutlet var lblHireabilityTag: UILabel!

    @IBOutlet var tvNote: UITextView!
    @IBOutlet var btnSave: UIButton!
    
    @IBOutlet var nameTopContraint: NSLayoutConstraint!
    @IBOutlet var bioTopConstraint: NSLayoutConstraint!
    
    var viewModel: ProfileViewModel!
    
    func skeletonize(view:  UIView) {
        view.isSkeletonable = true
        view.skeletonCornerRadius = 2.0
        view.showAnimatedGradientSkeleton()
        view.startSkeletonAnimation()
    }
    
    func skeletonize(label: UILabel) {
        label.numberOfLines = 0
        label.isSkeletonable = true
        label.skeletonCornerRadius = 2.0
        label.skeletonPaddingInsets = UIEdgeInsets(top: 0, left: 0, bottom: label.frame.height, right: label.frame.width)
        label.showAnimatedGradientSkeleton()
    }
    
    
    func showSkeletons() {
        let tags = [lblCompanyTag, lblBlogTag, lblLocationTag, lblEmailTag, lblHireabilityTag]
        let values = [lblName, lblLogin, lblBio, lblFollow, lblCompany, lblBlog, lblLocation, lblEmail, lblHireability]
        let views = [boxBlue, tvNote, btnSave ]
        tags.forEach { self.skeletonize(label: $0!) }
        values.forEach { self.skeletonize(label: $0!) }
        views.forEach { self.skeletonize(view: $0!) }
    }
    
    func hideSkeletons() {
        let tags = [lblCompanyTag, lblBlogTag, lblLocationTag, lblEmailTag, lblHireabilityTag]
        let values = [lblName, lblLogin, lblBio, lblFollow, lblCompany, lblBlog, lblLocation, lblEmail, lblHireability]
        let views = [tvNote, btnSave ]
        tags.forEach { $0?.hideSkeleton() }
        values.forEach { $0?.hideSkeleton() }
        views.forEach { $0?.hideSkeleton() }
    }
    
    private func setupLayout() {

        tvNote.layer.borderColor = UIColor.systemGray.cgColor
        tvNote.layer.borderWidth = 0
        tvNote.layer.cornerRadius = 10
        tvNote.backgroundColor = .systemGray5
        
        boxBlue.layer.borderWidth = 3.0
        boxBlue.layer.masksToBounds = false
        boxBlue.layer.borderColor = UIColor.white.cgColor
        boxBlue.layer.cornerRadius = boxBlue.frame.size.width / 2
        boxBlue.clipsToBounds = true
        
        showSkeletons()
        

//        self.lblName.skeletonPaddingInsets = UIEdgeInsets(top: 0, left: 0, bottom: self.lblName.frame.height, right: self.lblName.frame.width)
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(3000)) {
//            self.lblName.hideSkeleton()
//        }
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
        self.viewModel.delegate = self
        self.viewModel.bind {
            print(self.viewModel.userInfo ?? "NO_USER_INFO")
        }
        self.viewModel.fetchUserDetails(for: self.viewModel.user)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

}

extension ProfileViewController: ViewModelDelegate {
    func onDataAvailable() {
        print("Profile data available")
        let presented = self.viewModel.userInfo.presented
        DispatchQueue.main.async {
            self.lblName.text = presented.name
            if presented.name.isEmpty {
                self.nameTopContraint.constant = 9
            }
            self.lblLogin.text = presented.login
            self.lblBio.text = presented.bio
            if presented.bio.isEmpty {
                self.bioTopConstraint.constant = 0
            }
            self.lblCompany.text = presented.company
            self.lblBlog.text = presented.blog
            self.lblLocation.text = presented.location
            self.lblEmail.text = presented.email
            self.lblHireability.text = presented.hireability
            self.hideSkeletons()
        }
    }
    
    func onRetryError(n: Int, nextAttemptInMilliseconds: Int, error: Error) {
        print("\(#function)")
    }
    
func onFetchInProgress() {
        print("\(#function)")
    }
    
    func onFetchDone() {
        print("\(#function)")
    }
    
}
