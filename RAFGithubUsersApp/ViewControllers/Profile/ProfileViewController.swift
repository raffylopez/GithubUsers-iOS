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
    var delegate: ProfileViewDelegate! = nil
    @IBOutlet var boxBlue: UIView!
    @IBOutlet var imgUser: UIImageView!
    
    @IBOutlet var scrollView: UIScrollView!
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
    @IBOutlet var btnClear: UIButton!
    
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
        let views = [boxBlue, tvNote, btnSave, btnClear ]
        tags.forEach { self.skeletonize(label: $0!) }
        values.forEach { self.skeletonize(label: $0!) }
        views.forEach { self.skeletonize(view: $0!) }
    }
    
    private func hideSkeletons() {
        let tags = [lblCompanyIcon, lblBlogIcon, lblEmailIcon, lblHirabilityIcon, lblNoteIcon, lblCompanyTag, lblBlogTag, lblLocationIcon, lblEmailTag, lblHireabilityTag, lblNoteTag]
        let values = [lblName, lblLogin, lblBio, lblFollow, lblCompany, lblBlog, lblLocation, lblEmail, lblHireability]
        let views = [tvNote, btnSave, btnClear ]
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
        
        btnSave.layer.cornerRadius = 5
        btnSave.addTarget(self, action: #selector(btnSavePressed), for: .touchUpInside)

        btnClear.setTitleColor(.red, for: .selected)
        btnClear.layer.cornerRadius = 5
        btnClear.layer.borderColor = UIColor.systemGray6.cgColor
        btnClear.addTarget(self, action: #selector(btnClearPressed), for: .touchUpInside)

        btnClear.clipsToBounds = true
        btnSave.clipsToBounds = true
        UIHelper.configureAttributedLabelWithIcon(label: self.lblCompanyIcon, icon: .building)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblBlogIcon, icon: .globe, style: .solid)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblLocationIcon, icon: .mapMarker, style: .solid)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblEmailIcon, icon: .envelope)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblHirabilityIcon, icon: .briefcase, style: .solid)
        UIHelper.configureAttributedLabelWithIcon(label: self.lblNoteIcon, icon: .stickyNote)

        showSkeletons()
    }
    
    @objc func btnClearPressed() {
        self.tvNote.text = ""
        if let userInfo = self.viewModel.user.userInfo {
            userInfo.note = self.tvNote.text
            userInfo.user = self.viewModel.user
            do {
                try self.viewModel.databaseService.save()
            } catch {
                preconditionFailure("Unable to save note! \(error)")
            }
            delegate.didSaveNote(at: self.viewModel.cell.indexPath)
            
            let message = "Note deleted.".localized()
            if UIApplication.shared.isKeyboardPresented {
                ToastAlertMessageDisplay.main.displayTop(message: message)
                return
            }
            ToastAlertMessageDisplay.main.display(message: message)
            return
        }
    }
    
    @objc func btnSavePressed() {
        let hcolor = UIColor(red: 28/255, green: 107/255, blue: 43/255, alpha: 1)
        btnSave.setBackgroundColor(hcolor, for: .focused)
        btnSave.setBackgroundColor(hcolor, for: .highlighted)
        btnSave.setBackgroundColor(hcolor, for: .selected)
//        btnSave.setTitleColor(hcolor, for: .focused)
//        btnSave.setTitleColor(hcolor, for: .highlighted)
//        btnSave.setTitleColor(hcolor, for: .selected)
        if let userInfo = self.viewModel.user.userInfo {
            userInfo.note = self.tvNote.text
            userInfo.user = self.viewModel.user
            do {
                try self.viewModel.databaseService.save()
            } catch {
                preconditionFailure("Unable to save note! \(error)")
            }
            delegate.didSaveNote(at: self.viewModel.cell.indexPath)
            
            let message = "Note saved.".localized()
            if UIApplication.shared.isKeyboardPresented {
                ToastAlertMessageDisplay.main.displayTop(message: message)
                return
            }
            ToastAlertMessageDisplay.main.display(message: message)
            return
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
            print(self.viewModel.user.userInfo ?? "NO_USER_INFO")
        }

        self.viewModel.fetchUserDetails(for: self.viewModel.user, onRetryError: nil) { _ in
        }
        registerForKeyboardNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func registerForKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardAppear(_:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onKeyboardDisappear(_:)), name: UIResponder.keyboardDidHideNotification, object: nil)
    }
    
    @objc func onKeyboardAppear(_ notification: NSNotification) {
        let info = notification.userInfo!
        let rect: CGRect = info[UIResponder.keyboardFrameBeginUserInfoKey] as! CGRect
        let kbSize = rect.size
        let kbHeight = kbSize.height - (self.btnSave.frame.height * 2)

        let insets = UIEdgeInsets(top: 0, left: 0, bottom: kbHeight, right: 0)
        scrollView.contentInset = insets
        scrollView.scrollIndicatorInsets = insets
        
        var aRect = self.view.frame;
        aRect.size.height -= kbHeight;
        
        let activeField: UITextView? = [tvNote].first { $0.isFirstResponder }
        if let activeField = activeField {
            if !aRect.contains(activeField.frame.origin) {
                let scrollPoint = CGPoint(x: 0, y: activeField.frame.origin.y-kbHeight)
                scrollView.setContentOffset(scrollPoint, animated: true)
            }
        }
    }
    
    @objc func onKeyboardDisappear(_ notification: NSNotification) {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
    }
}

extension ProfileViewController: ViewModelDelegate {
    func onDataAvailable() {
        if let userInfo = self.viewModel.user.userInfo {
            let presented = userInfo.presented
            delegate.didSeeProfile(at: self.viewModel.cell.indexPath)
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

extension UIApplication {
    var isKeyboardPresented: Bool {
        if let keyboardWindowClass = NSClassFromString("UIRemoteKeyboardWindow"), self.windows.contains(where: { $0.isKind(of: keyboardWindowClass) }) {
            return true
        } else {
            return false
        }
    }
}
