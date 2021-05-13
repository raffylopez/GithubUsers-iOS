//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class InvertedUserTableViewCell: UserTableViewCellBase {
    let store: ImageStore = ImageStore()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}

extension InvertedUserTableViewCell: UserTableViewCell {
    /**
     Wraps image inversion in asynchronous call
     */
    func invertImage(image: UIImage, completion: @escaping (UIImage?)->()) {
        DispatchQueue.global(qos: .userInteractive).async {
            let invertedImage = image.invertImageColors()
            completion(invertedImage)
        }
    }
    
    func update(displaying image: (UIImage, ImageSource)?) {
        if let imageResultSet = image {
            
            let image = imageResultSet.0
            let imageSource = imageResultSet.1

            switch imageSource {
            case .network:
                self.invertImage(image: image) { img in
                    OperationQueue.main.addOperation {
                        self.imgViewChar.image = img
                    }
                }
            case .cache:
                OperationQueue.main.addOperation {
                    self.imgViewChar.image = image
                }
                self.spinner.stopAnimating()
            }
            return
        }
    }
}
