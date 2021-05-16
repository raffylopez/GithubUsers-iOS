//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class SkeletonizedTableViewCell: UserTableViewCellBase {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func updateWith(user: User) {
        skeletonize(view: self.imgViewChar)
        skeletonize(label: self.lblName)
        skeletonize(label: self.lblSeries)
        super.updateWith(user: user)
        self.lblName.text = self.lblName.text ?? ""
    }

    private func unskeletonize(view:  UIView) {
        view.backgroundColor = .systemBackground
    }
    
    private func unskeletonize(label:  UILabel) {
        label.backgroundColor = .systemBackground
        label.textColor = .systemBackground
    }
    private func skeletonize(view:  UIView) {
        view.backgroundColor = .systemGray5
    }
    
    private func skeletonize(label:  UILabel) {
        label.backgroundColor = .systemGray5
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
}

extension ShimmerTableViewCell: UserTableViewCell {

    func update(displaying image: (UIImage, ImageSource)?) {
        if let imageResultSet = image {
            let image = imageResultSet.0
            let imageSource = imageResultSet.1
            
            UIView.transition(with: self.imgViewChar, duration: 2.5, options: .transitionCrossDissolve, animations: {
                self.unskeletonize(view: self.imgViewChar)
                self.unskeletonize(label: self.lblSeries)
                self.unskeletonize(label: self.lblName)
                self.imgViewChar.image = image
            }, completion: { _ in
            })
            return
        }
    }
}
