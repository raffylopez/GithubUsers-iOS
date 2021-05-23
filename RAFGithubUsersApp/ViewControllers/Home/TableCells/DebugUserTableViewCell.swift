//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
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
            self.backgroundColor = .systemGray2
        } else {
            self.backgroundColor = .systemBackground
            self.lblSeries.text = "updated"
        }
    }
}
