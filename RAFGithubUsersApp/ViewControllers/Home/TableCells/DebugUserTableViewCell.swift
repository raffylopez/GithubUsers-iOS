//
//  DebugUserTableViewCell.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

class DebugUserTableViewCell: NormalUserTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override internal func updateCell() {
        self.lblName.text = "\(user.id) - \(user.login ?? "-")"
        guard let controller = self.owningController as? UsersViewController else {
            return
        }
        
        if controller.viewModel.staleIds.firstIndex(of: self.user.id) != nil  {
            self.lblSeries.text = "stale"
            self.lblSeries.textColor = .systemBackground
            self.backgroundColor = .pomegranate
        } else {
            self.backgroundColor = .systemBackground
            self.lblSeries.text = "updated"
        }
    }
}

class DebugNotedUserTableViewCell: DebugUserTableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    let lblStickyNote = UILabel()
    override func setupViews() {
        super.setupViews()
        UIHelper.initializeView(view: lblStickyNote, parent: self)
        
        lblStickyNote.font = UIFont.fontAwesome(ofSize: 20, style: .regular)
        lblStickyNote.text = String.fontAwesomeIcon(name: .stickyNote)
        
        lblStickyNote.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        lblStickyNote.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20).isActive = true
    }
}
