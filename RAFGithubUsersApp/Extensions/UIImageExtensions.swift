//
//  UIImageExtensions.swift
//  RAFGithubUsersApp
//
//  Created by Volare on 5/13/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import Foundation

extension UIImage {
    func invertImageColors() -> UIImage? {
        let theImage = self
        guard let filter = CIFilter(name: "CIColorInvert") else { return nil }
        filter.setValue(CIImage(image: theImage), forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else { return nil }
        let newImage = UIImage(ciImage: outputImage)
        return newImage
    }
}
