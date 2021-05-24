//
//  InvertedUserTableViewCell.swift
//  RAF_GithubUsersApp
//
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
    
    override func update(displaying image: (UIImage, ImageSource)?) {
        DispatchQueue.global().async {
            if let imageResultSet = image {
                let image = imageResultSet.0
                image.invertImageColorsAsync { invertedImage in
                    DispatchQueue.main.async {
                        self.imgViewChar.image = invertedImage
                        self.spinner?.stopAnimating()
                    }
                }
                return
            }
        }
    }
    
}

extension InvertedUserTableViewCell: UserTableViewCell {
    /**
     Wraps image inversion in asynchronous call, and places the routine into a
     high performance queue.
     
     Images are only inverted after network retrieval. The inverted
     image is stored into the image cache afterwards. This leads to a palpably less
     laggy tableview scrolling experience.
     
     TODO: Implement look-ahead image inversion for even better performance.
     */
    func invertImage(image: UIImage, completion: @escaping (UIImage?)->()) {
        DispatchQueue.global(qos: .userInteractive).async {
            let invertedImage = image.invertImageColors()
            completion(invertedImage)
        }
    }
    
}
