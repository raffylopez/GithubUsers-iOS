//
//  UIHelper.swift
//  RDLAmiiboApp
//
//  Created by Volare on 4/16/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation
import UIKit
 
// MARK: - UIHelper
enum UIHelper {
    public static func initializeView<T>(view: T, parent: T?) where T: UIView {
        view.translatesAutoresizingMaskIntoConstraints = false
        parent?.addSubview(view)
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
/**
 Displays a toast message at the bottom of the first window's nav
 controller.
 
 Navigation controller should be the receiver, otherwise toast
 might be misplaced or obscured.
 
 Display is always performed in the main queue
 */
func makeToast(message:String, duration: TimeInterval) {
    DispatchQueue.main.async {
        UIApplication.shared.windows.first?.rootViewController?.view.makeToast(message)
    }
}
