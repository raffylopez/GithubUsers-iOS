//
//  UIImage.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

/** Support for image color inversion */
extension UIImage {
    func invertImageColorsAsync(completion: @escaping(UIImage?)->Void) {
        let theImage = self
        guard let filter = CIFilter(name: "CIColorInvert") else {
            completion(nil)
            return
        }
        filter.setValue(CIImage(image: theImage), forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else {
            completion(nil)
            return
        }
        let newImage = UIImage(ciImage: outputImage)
        completion(newImage)
    }
    func invertImageColors() -> UIImage? {
        let theImage = self
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(CIImage(image: theImage), forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else { return nil }
        let newImage = UIImage(ciImage: outputImage)
        return newImage
    }
    
    func resizeImage(newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
