//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class NormalUserTableViewCell: UserTableViewCellBase {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func prepareForReuse() {
        imgViewChar.backgroundColor = .systemBackground
        imgViewChar.image = nil
        spinner.startAnimating()
    }
    
    fileprivate func makeImageVisible(img: UIImage) {
        self.imgViewChar.layer.opacity = 1
        self.imgViewChar.image = img
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        switch touch.view {
        case imgViewChar:
            guard let imgCharThumbnail = imgViewChar else { break }
            delegate?.didTouchImageThumbnail(view: imgCharThumbnail, cell: self, element: self.amiiboElement)
        default:
            delegate?.didTouchCellPanel(cell: self)
        }
    }
}

extension NormalUserTableViewCell: UserTableViewCell {
    
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
