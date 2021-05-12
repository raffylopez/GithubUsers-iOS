//
//  StringExtensions.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
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
