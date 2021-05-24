//
//  NoteInvertedUserTableViewCell.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class NoteInvertedUserTableViewCell: InvertedUserTableViewCell {

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
