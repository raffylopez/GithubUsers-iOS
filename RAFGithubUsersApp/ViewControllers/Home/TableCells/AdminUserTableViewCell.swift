//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class AdminUserTableViewCell: UserTableViewCellBase {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override internal func updateWith(user: User, indexPath: IndexPath) {
        super.updateWith(user: user, indexPath: indexPath)
        self.lblName.textColor = .red
    }

}

extension AdminUserTableViewCell: UserTableViewCell {
    func update(displaying image: (UIImage, ImageSource)?) {
        if let imageResultSet = image {
            let image = imageResultSet.0
            let imageSource = imageResultSet.1
            
            switch imageSource {
            case .network:
                UIView.transition(with: self.imgViewChar, duration: 0.25, options: .transitionCrossDissolve, animations: {
                    self.imgViewChar.image = image
                }, completion: { _ in
                    self.spinner.stopAnimating()
                })
            case .cache:
                self.imgViewChar.image = image
                self.spinner.stopAnimating()
            }
            return
        }
    }
    
}
