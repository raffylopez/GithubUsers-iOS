//
//  ViewController.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/11/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit
import SkeletonView

protocol UIAlertMessageDisplay {
    func display(message: String)
}

class ToastAlertMessageDisplay: UIAlertMessageDisplay {
    static let shared = ToastAlertMessageDisplay()
    static let appView = UIApplication.shared.windows.first?.rootViewController?.view
    func display(message: String) {
        OperationQueue.main.addOperation {
            Self.appView?.makeToast(message)
        }
    }
    func hideAllToasts() {
        OperationQueue.main.addOperation {
            Self.appView?.hideAllToasts()
        }
    }
    func makeToastActivity() {
        OperationQueue.main.addOperation {
            Self.appView?.makeToastActivity(.bottom)
        }
    }
    func hideToastActivity() {
        OperationQueue.main.addOperation {
            Self.appView?.hideToastActivity()
        }
        
    }
}

class StandardAlertMessageDisplay: UIAlertMessageDisplay {
    static let shared = StandardAlertMessageDisplay()
    func display(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Note saved", message: "Your note has been saved", preferredStyle: .actionSheet)
            let action = UIAlertAction(title: "OK", style: .default) { action in }
            alert.addAction(action)
            UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

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
    @IBOutlet var lblLocationTag: UILabel!
    @IBOutlet var lblEmailTag: UILabel!
    @IBOutlet var lblHireabilityTag: UILabel!
    @IBOutlet var lblNoteTag: UILabel!
    
    @IBOutlet var tvNote: UITextView!
    @IBOutlet var btnSave: UIButton!
    
    @IBOutlet var nameTopContraint: NSLayoutConstraint!
    @IBOutlet var bioTopConstraint: NSLayoutConstraint!
    
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
        let tags = [lblCompanyTag, lblBlogTag, lblLocationTag, lblEmailTag, lblHireabilityTag, lblNoteTag]
        let values = [lblName, lblLogin, lblBio, lblFollow, lblCompany, lblBlog, lblLocation, lblEmail, lblHireability]
        let views = [boxBlue, tvNote, btnSave ]
        tags.forEach { self.skeletonize(label: $0!) }
        values.forEach { self.skeletonize(label: $0!) }
        views.forEach { self.skeletonize(view: $0!) }
    }
    
    private func hideSkeletons() {
        let tags = [lblCompanyTag, lblBlogTag, lblLocationTag, lblEmailTag, lblHireabilityTag, lblNoteTag]
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
        showSkeletons()
    }
    
    @objc func btnSavePressed() {
        let managedUser = self.viewModel.databaseService.getUserInfo(with: Int(self.viewModel.userInfo.id))
        managedUser?.note = self.tvNote.text
        do {
            try self.viewModel.databaseService.save()
        } catch {
            preconditionFailure("Unable to save note! \(error)")
        }
        ToastAlertMessageDisplay.shared.display(message: "Note saved.")
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
            self.lblFollow.text = "\(presented.followers) followers • \(presented.following) following"
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
