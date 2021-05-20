//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class NoteUserTableViewCell: UserTableViewCellBase {
    let lblStickyNote = UILabel()
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setupViews() {
        super.setupViews()
        UIHelper.initializeView(view: lblStickyNote, parent: self)
        
        lblStickyNote.font = UIFont.fontAwesome(ofSize: 20, style: .regular)
        lblStickyNote.text = String.fontAwesomeIcon(name: .stickyNote)

        lblStickyNote.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lblStickyNote.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
    }
}

extension NoteUserTableViewCell: UserTableViewCell {
    
    func update(displaying image: (UIImage, ImageSource)?) {
        if let imageResultSet = image {
            let image = imageResultSet.0
            let imageSource = imageResultSet.1
            
            switch imageSource {
            case .network:
                OperationQueue.main.addOperation {
                    UIView.transition(with: self.imgViewChar, duration: 0.25, options: .transitionCrossDissolve, animations: {
                        self.imgViewChar.image = image
                    }, completion: { _ in
                        self.spinner.stopAnimating()
                    })
                }
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

