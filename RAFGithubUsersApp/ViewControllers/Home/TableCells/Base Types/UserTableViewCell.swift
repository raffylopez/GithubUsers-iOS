//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

protocol UserTableViewCell: UITableViewCell {
    func update(displaying image: (UIImage, ImageSource)?)
    func updateWith(user: User)
}
