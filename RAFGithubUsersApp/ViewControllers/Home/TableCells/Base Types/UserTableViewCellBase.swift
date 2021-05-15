//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit
import SkeletonView

class UserTableViewCellBase: UITableViewCell {
    var user: User!
    weak var delegate: UserListTableViewCellDelegate?
    
    var spinner: UIActivityIndicatorView! = {
        let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    internal var imgViewChar: UIImageView! = {
        let imgCharacter = UIImageView()
        imgCharacter.backgroundColor = .systemBackground
        imgCharacter.isUserInteractionEnabled = true
        imgCharacter.contentMode = .scaleAspectFit
        return imgCharacter }()
    
    internal var lblName: UILabel! = {
        let lblName = UILabel()
        lblName.font = UIFont.boldSystemFont(ofSize: 18)
        return lblName }()
    
    internal lazy var lblSeries: UILabel! = {
        let lblSeries = UILabel()
        lblSeries.font = UIFont.systemFont(ofSize: 15)
        let graylvl: CGFloat = 100
        lblSeries.textColor = UIColor(red: graylvl/255, green: graylvl/255, blue: graylvl/255, alpha: 1)
        return lblSeries }()

    internal lazy var stackView: UIStackView? = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.axis = .vertical
        return stackView }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupViews()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    internal func setupViews() {
        guard let lblName = lblName,
            let lblSeries = lblSeries,
            let imgCharacter = imgViewChar,
            let stackView = stackView else { return }
        
        stackView.addArrangedSubview(lblName)
        stackView.addArrangedSubview(lblSeries)
        
        UIHelper.initializeView(view: lblSeries, parent: nil)
        UIHelper.initializeView(view: lblName, parent: nil)
        UIHelper.initializeView(view: imgCharacter, parent: self)
        UIHelper.initializeView(view: stackView, parent: self)
        UIHelper.initializeView(view: spinner, parent: self)
        
        spinner.centerYAnchor.constraint(equalTo: imgCharacter.centerYAnchor).isActive = true
        spinner.centerXAnchor.constraint(equalTo: imgCharacter.centerXAnchor).isActive = true
//        imgCharacter.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        spinner.startAnimating()
    }
    
    internal func setupLayout() {
        guard let imgCharacter = imgViewChar,
            let stackView = stackView else { return }
        
        stackView.resizeDimensions(width: 200)
        imgCharacter.resizeDimensions(height: 100, width: 100)
        
        let views = ["nm": stackView, "img": imgCharacter]
        NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal,
                           toItem: stackView.superview, attribute: .centerY,
                           multiplier: 1, constant: -5).isActive = true
        
        let hcn = NSLayoutConstraint
            .constraints(withVisualFormat: "H:[img]-15-[nm]", metrics: nil, views: views)
        NSLayoutConstraint.activate(hcn)
    }
    
    func updateWith(user: User) {
        self.lblName.text = user.login
        self.lblSeries.text = user.urlHtml
    }
}

// MARK: - Custom Methods
extension UserTableViewCellBase {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.didTouchCellPanel(cell: self)
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

}

