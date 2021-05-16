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

    override func updateWith(user: User) {
        super.updateWith(user: user)
        self.lblName.text = self.lblName.text ?? ""
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
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
    
    func update(displaying image: (UIImage, ImageSource)?) {
        if let imageResultSet = image {
            
            let image = imageResultSet.0
            let imageSource = imageResultSet.1
            
            switch imageSource {
            case .network:
                OperationQueue.main.addOperation {
                    if let invertedImage = image.invertImageColors() {
                        self.imgViewChar.image = invertedImage
                        self.store.setImage(forKey: "\(self.user.id)", image: invertedImage)
                        self.spinner.stopAnimating()
                    }
                }
                return
            case .cache:
                OperationQueue.main.addOperation {
                    self.imgViewChar.image = image
                    self.spinner.stopAnimating()
                }
            }
            return
        }
    }
}
