//
//  SkelHelper.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

class SkelHelper {
    
    public static func skeletonize(view:  UIView) {
        view.isSkeletonable = true
        view.skeletonCornerRadius = 2.0
        view.showAnimatedGradientSkeleton()
        view.startSkeletonAnimation()
    }
    
    public static func skeletonize(label: UILabel) {
        label.numberOfLines = 0
        label.isSkeletonable = true
        label.skeletonCornerRadius = 2.0
        label.skeletonPaddingInsets = UIEdgeInsets(top: 0, left: 0, bottom: label.frame.height, right: label.frame.width)
        label.showAnimatedGradientSkeleton()
    }
    
}
