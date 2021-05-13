//
//  ImageStore.swift
//  LootLogger2
//
//  Created by Volare on 2/28/21.
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit
import Foundation

// MARK: - ImageStore

/**
 Class for persisting media into disk (document sandbox), with support
 for in-memory caching
 */
class ImageStore {
    public static var compressionQuality: CGFloat {
        get { return compressionQualityBacking }
        set { compressionQualityBacking = newValue }
    }
    private static var compressionQualityBacking: CGFloat = 0.5

    let cache = NSCache<NSString, UIImage>()
    
    private func imageUrl(forKey key: String) -> URL {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        var baseDir = url.first!
        baseDir.appendPathComponent(key)
        return baseDir
    }

    /**
     Retrieve image given a string key
     */
    @discardableResult func image(forKey key: String) -> UIImage? {
        if let cachedImg = cache.object(forKey: key as NSString) {
            return cachedImg
        }
        
        let persistentImgUrl = imageUrl(forKey: key)
        guard let persistentImg = UIImage(contentsOfFile: persistentImgUrl.path) else {
            return nil
        }
        return persistentImg
    }

    /**
     Persists image to cache and documment sandbox
     */
    func setImage(forKey key: String, image: UIImage) {
        cache.setObject(image, forKey: key as NSString)
        let url = imageUrl(forKey: key)
        if let data = image.jpegData(compressionQuality: Self.compressionQuality) {
            try? data.write(to: url)
        } else {
            fatalError("Can't save image into docs directory")
        }
    }
    
    /**
     Deletes an image given a string key
     */
    func removeImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
        let persistentImgUrl = imageUrl(forKey: key)
        do {
            try FileManager.default.removeItem(at: persistentImgUrl)
        } catch let err {
            print("Unable to remove corresponding file from disk: \(err)")
        }
    }
}
