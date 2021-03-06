//
//  ShimmerTableViewCell.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class ShimmerTableViewCell: UserTableViewCellBase {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func skeletonize(view:  UIView) {
        view.isSkeletonable = true
        view.skeletonCornerRadius = 2.0
        view.showAnimatedGradientSkeleton()
    }
    
    private func skeletonize(label:  UILabel) {
        label.isSkeletonable = true
        label.skeletonCornerRadius = 2.0
        label.showAnimatedGradientSkeleton()
    }
    
    private func unskeletonize(label:  UILabel) {
        label.hideSkeleton()
    }
    
    override internal func setupViews() {
        guard let lblName = lblName,
            let lblSeries = lblSeries,
            let imgCharacter = imgViewChar,
            let stackView = stackView else { return }
        
        stackView.addArrangedSubview(lblName)
        stackView.addArrangedSubview(lblSeries)
        
        UIHelper.initializeView(view: lblSeries, parent: nil)
        UIHelper.initializeView(view: lblName, parent: nil)
        UIHelper.initializeView(view: imgCharacter, parent: self)
        UIHelper.initializeView(view: stackView, parent: self)
    }
    
    override func update(displaying image: (UIImage, ImageSource)?) {
        if let imageResultSet = image {
            let image = imageResultSet.0
            let imageSource = imageResultSet.1
            
            switch imageSource {
            case .network:
                OperationQueue.main.addOperation {
                    self.imgViewChar.image = image
                    self.imgViewChar.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.3))
                }
            case .cache:
                OperationQueue.main.addOperation {
                    self.imgViewChar.image = image
                    self.imgViewChar.hideSkeleton(reloadDataAfter: true, transition: .crossDissolve(0.25))
                }
            }
            return
        }
    }
}

