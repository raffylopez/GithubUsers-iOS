//
//  UIHelper.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import UIKit
import FontAwesome

// MARK: - UIHelper
enum UIHelper {
    public static func initializeView<T>(view: T, parent: T?) where T: UIView {
        view.translatesAutoresizingMaskIntoConstraints = false
        parent?.addSubview(view)
    }
    public static func configureLabelWithIcon(label: UILabel, icon: FontAwesome, style: FontAwesomeStyle = .regular, prepend: Bool = false) {
        guard let labelText = label.text else { return }
        let fontSize = label.font.pointSize
        let iconText = prepend ? "\(String.fontAwesomeIcon(name: icon)) \(labelText)": String.fontAwesomeIcon(name: icon)
        let fontFontAwesome = UIFont.fontAwesome(ofSize: fontSize, style: style)
        label.font = fontFontAwesome
        
        DispatchQueue.main.async {
            label.text = iconText
        }
    }
    
    public static func configureAttributedLabelWithIcon(label: UILabel, icon: FontAwesome, style: FontAwesomeStyle = .regular, prepend: Bool = false) {
        guard let labelText = label.attributedText else { return }
        let fontSize = label.font.pointSize
        let iconText = prepend ? "\(String.fontAwesomeIcon(name: icon)) ": String.fontAwesomeIcon(name: icon)
        let fontFontAwesome = UIFont.fontAwesome(ofSize: fontSize, style: style)
        let iconTextAttributed = NSMutableAttributedString(string:iconText, attributes: [NSAttributedString.Key.font: fontFontAwesome])
        if prepend {
            let mutableAttributedText = NSMutableAttributedString(attributedString: labelText)
            iconTextAttributed.append(mutableAttributedText)
        }
        DispatchQueue.main.async {
            label.attributedText = iconTextAttributed
        }
    }
}

extension UIImage {
    func removeAlpha() -> UIImage {
        let inputImage = self
        let format = UIGraphicsImageRendererFormat.init()
        format.opaque = true // Removes Alpha Channel
        format.scale = inputImage.scale // Keeps original image scale.
        let size = inputImage.size
        return UIGraphicsImageRenderer(size: size, format: format).image { _ in
            inputImage.draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
