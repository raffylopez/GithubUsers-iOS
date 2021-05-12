//
//  AmiiboCharacterListViewCell.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit

// MARK: - AmiiboCharacterListViewCellDelegate
protocol AmiiboCharacterListViewCellDelegate: class {
    func didTouchImageThumbnail(view: UIImageView, cell: AmiiboCharacterListViewCell, element: User)
    func didTouchCellPanel(cell: AmiiboCharacterListViewCell)
}

// MARK: - AmiiboCharacterListViewCell
class AmiiboCharacterListViewCell: UITableViewCell {
    var amiiboElement: User!
    weak var delegate: AmiiboCharacterListViewCellDelegate?
    
    var spinner: UIActivityIndicatorView! = {
       let spinner = UIActivityIndicatorView()
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private var imgViewChar: UIImageView! = {
        let imgCharacter = UIImageView()
        imgCharacter.backgroundColor = .systemYellow
        imgCharacter.isUserInteractionEnabled = true
        imgCharacter.contentMode = .scaleAspectFit
        return imgCharacter }()
    
    lazy var lblName: UILabel! = {
        let lblName = UILabel()
        lblName.font = UIFont.boldSystemFont(ofSize: 18)
        return lblName }()
    
    lazy var lblSeries: UILabel! = {
        let lblSeries = UILabel()
        lblSeries.font = UIFont.systemFont(ofSize: 15)
        return lblSeries }()

    private lazy var stackView: UIStackView? = {
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
    
    fileprivate func setupViews() {
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
        spinner.startAnimating()
    }
    
    fileprivate func setupLayout() {
        guard let imgCharacter = imgViewChar,
            let stackView = stackView else { return }
        
        stackView.resizeDimensions(width: 200)
        imgCharacter.resizeDimensions(height: 130, width: 100)
        
        let views = ["nm": stackView, "img": imgCharacter]
        NSLayoutConstraint(item: stackView, attribute: .centerY, relatedBy: .equal,
                           toItem: stackView.superview, attribute: .centerY,
                           multiplier: 1, constant: -5).isActive = true
        
        let hcn = NSLayoutConstraint
            .constraints(withVisualFormat: "H:[img]-15-[nm]", metrics: nil, views: views)
        NSLayoutConstraint.activate(hcn)
    }
}

// MARK: - Custom Methods
extension AmiiboCharacterListViewCell {
    
    override func prepareForReuse() {
        imgViewChar.backgroundColor = .systemYellow
        imgViewChar.image = nil
        spinner.startAnimating()
    }
    
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
//        imgCharacter.layer.opacity = 0
//        imgCharacter.image = nil
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

fileprivate extension UIView {
    func resizeDimensions(height: CGFloat? = nil, width: CGFloat? = nil) {
        if let height = height {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if let width = width {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
}
