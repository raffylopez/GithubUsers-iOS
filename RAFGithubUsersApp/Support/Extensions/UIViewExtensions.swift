//
//  UIView.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

extension UIView {
    func resizeDimensions(height: CGFloat? = nil, width: CGFloat? = nil) {
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
}
