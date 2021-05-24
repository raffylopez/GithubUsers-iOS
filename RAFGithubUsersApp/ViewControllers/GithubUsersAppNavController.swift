//
//  GithubUsersAppNavController.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

/* Main navigation view controller, with UI support for reachability monitor */
class GithubUsersAppNavController: UINavigationController {
    
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var statusBarBottomConstraint: NSLayoutConstraint? = nil
    var label = UILabel()
    
    lazy var statusBar: UIView = {
        let statusBar = UIView()
        UIHelper.initializeView(view: statusBar, parent: self.view)
        statusBar.backgroundColor = .red
        
        label.text = "No network"
        label.textColor = .white
        label.sizeToFit()
        UIHelper.initializeView(view: label, parent: statusBar)
        label.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: statusBar.leadingAnchor, constant: 20).isActive = true
        
        return statusBar
    }()
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(self, selector:#selector(self.onNetworkReachable), name: NSNotification.Name.connectionDidBecomeReachable, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.onNetworkUnreachable), name: NSNotification.Name.connectionDidBecomeUnreachable, object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.onServerError), name: NSNotification.Name.serverDidError, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupObservers()
    }
    
    override func loadView() {
        super.loadView()
        self.statusBar.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 1).isActive = true
        self.statusBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        self.statusBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        self.statusBar.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.statusBarBottomConstraint = NSLayoutConstraint(item: self.statusBar, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 40)
        self.statusBarBottomConstraint?.isActive = true
        self.view.layoutIfNeeded()
    }
    
    @objc func onServerError() {
        self.view.layoutIfNeeded()
        label.text = "Server error".localized()
        self.statusBar.backgroundColor = .red
        UIView.animate(withDuration: 0.3) {
            self.statusBarBottomConstraint?.constant = 0
            self.view.layoutIfNeeded()
        }
    }

    @objc func onNetworkReachable() {
        self.view.layoutIfNeeded()
        self.label.text = "Connected!".localized()
        let darkGreenColor = UIColor.init(red: 35/255, green: 134/255, blue: 53/255, alpha: 1.0)
        UIView.animate(withDuration: 0.75, animations: {
            self.statusBar.backgroundColor = darkGreenColor
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                UIView.animate(withDuration: 0.3) {
                    self.statusBarBottomConstraint?.constant = 40
                    self.view.layoutIfNeeded()
                }
            }
        })
    }
    
    @objc func onNetworkUnreachable() {
            self.view.layoutIfNeeded()
            label.text = "No Network".localized()
            self.statusBar.backgroundColor = .red
            UIView.animate(withDuration: 0.3) {
                self.statusBarBottomConstraint?.constant = 0
                self.view.layoutIfNeeded()
            }
    }
}

extension UINavigationController {
    
    func setStatusBar(backgroundColor: UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = view.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = backgroundColor
        view.addSubview(statusBarView)
    }
    
}
