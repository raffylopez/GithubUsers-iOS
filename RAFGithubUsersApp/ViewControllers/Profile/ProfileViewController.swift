//
//  ViewController.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit
import SkeletonView
import FontAwesome

class ProfileViewController: UIViewController {
    @IBOutlet var boxBlue: UIView!
    @IBOutlet var imgUser: UIImageView!
    
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
    @IBOutlet var lblLocationIcon: UILabel!
    @IBOutlet var lblEmailTag: UILabel!
    @IBOutlet var lblHireabilityTag: UILabel!
    @IBOutlet var lblNoteTag: UILabel!
    
    @IBOutlet var tvNote: UITextView!
    @IBOutlet var btnSave: UIButton!
    
    @IBOutlet var nameTopContraint: NSLayoutConstraint!
    @IBOutlet var bioTopConstraint: NSLayoutConstraint!
    
    @IBOutlet var lblNoteIcon: UILabel!
    @IBOutlet var lblHirabilityIcon: UILabel!
    @IBOutlet var lblEmailIcon: UILabel!
    @IBOutlet var lblBlogIcon: UILabel!
    @IBOutlet var lblCompanyIcon: UILabel!
    var viewModel: ProfileViewModel!
    
    private func skeletonize(view:  UIView) {
        view.isSkeletonable = true
        view.skeletonCornerRadius = 2.0
        view.showAnimatedGradientSkeleton()
        view.startSkeletonAnimation()
    }
    
    private func skeletonize(label: UILabel) {
        label.numberOfLines = 0
        label.isSkeletonable = true
        label.skeletonCornerRadius = 2.0
        label.skeletonPaddingInsets = UIEdgeInsets(top: 0, left: 0, bottom: label.frame.height, right: label.frame.width)
        label.showAnimatedGradientSkeleton()
    }
    
    private func showSkeletons() {
        let tags = [lblCompanyIcon, lblBlogIcon, lblEmailIcon, lblHirabilityIcon, lblNoteIcon, lblCompanyTag, lblBlogTag, lblLocationIcon, lblEmailTag, lblHireabilityTag, lblNoteTag]
        let values = [lblName, lblLogin, lblBio, lblFollow, lblCompany, lblBlog, lblLocation, lblEmail, lblHireability]
        let views = [boxBlue, tvNote, btnSave ]
        tags.forEach { self.skeletonize(label: $0!) }
        values.forEach { self.skeletonize(label: $0!) }
        views.forEach { self.skeletonize(view: $0!) }
    }
    
    private func hideSkeletons() {
        let tags = [lblCompanyIcon, lblBlogIcon, lblEmailIcon, lblHirabilityIcon, lblNoteIcon, lblCompanyTag, lblBlogTag, lblLocationIcon, lblEmailTag, lblHireabilityTag, lblNoteTag]
        let values = [lblName, lblLogin, lblBio, lblFollow, lblCompany, lblBlog, lblLocation, lblEmail, lblHireability]
        let views = [tvNote, btnSave ]
        tags.forEach { $0?.hideSkeleton() }
        values.forEach { $0?.hideSkeleton() }
        views.forEach { $0?.hideSkeleton() }
    }
    

    private func setupLayout() {
        tvNote.layer.borderColor = UIColor.systemGray.cgColor
        tvNote.layer.borderWidth = 0
        tvNote.layer.cornerRadius = 5
        tvNote.backgroundColor = UIColor.init(red: 239/255, green: 239/255, blue: 239/255, alpha: 1.0)
        
        boxBlue.layer.borderWidth = 3.0
        boxBlue.layer.masksToBounds = false
        boxBlue.layer.borderColor = UIColor.white.cgColor
        boxBlue.layer.cornerRadius = boxBlue.frame.size.width / 2
        boxBlue.clipsToBounds = true
        
        btnSave.setTitleColor(.red, for: .selected)
        
        btnSave.layer.cornerRadius = 5
        btnSave.addTarget(self, action: #selector(btnSavePressed), for: .touchDown)
        
        UIHelper.configureAttributedLabelWithIcon(label: self.lblCompanyIcon, icon: .building)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblBlogIcon, icon: .globe, style: .solid)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblLocationIcon, icon: .mapMarker, style: .solid)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblEmailIcon, icon: .envelope)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblHirabilityIcon, icon: .briefcase, style: .solid)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblNoteIcon, icon: .stickyNote)

        showSkeletons()
    }
    
    @objc func btnSavePressed() {
        if let userInfo = self.viewModel.userInfo {
            userInfo.note = self.tvNote.text
            userInfo.user = self.viewModel.user
            do {
                try self.viewModel.databaseService.save()
            } catch {
                preconditionFailure("Unable to save note! \(error)")
            }
            ToastAlertMessageDisplay.main.display(message: "Note saved.".localized())
        }
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

        ToastAlertMessageDisplay.main.makeToastActivity()
        self.viewModel.fetchUserDetails(for: self.viewModel.user, onRetryError: nil) { _ in
            ToastAlertMessageDisplay.main.hideToastActivity()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

extension ProfileViewController: ViewModelDelegate {
    func onDataAvailable() {
        let presented = self.viewModel.userInfo.presented
        OperationQueue.main.addOperation {
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
            let lblFollowText = "\(presented.followers) followers • \(presented.following) following"
            self.lblFollow.attributedText = NSAttributedString(string: lblFollowText)
            UIHelper.configureAttributedLabelWithIcon(label: self.lblFollow, icon: .userFriends, style: .solid, prepend: true)
            self.tvNote.text = presented.note
            self.hideSkeletons()
            self.viewModel.fetchImage(for: self.viewModel.user) { result in
                OperationQueue.main.addOperation {
                    if case let .success(img) = result {
                        self.imgUser.image = img.0
                        self.boxBlue.hideSkeleton()
                    }
                }
            }
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
