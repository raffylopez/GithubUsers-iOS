//
//  ImageStore.swift
//  RAF_GithubUsersApp
//
//  Copyright © 2021 Raf. All rights reserved.
//

import UIKit
import Foundation

// MARK: - ImageStore

/**
 Allows for persistence of images into dual stores (document app directory and in-memory NSCache)
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
            fatalError("Can't save image into docs directory") // TODO
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
    
    /**
     Clears all cached media from NSCache and app documents
     */
    func removeAllImages() {
        cache.removeAllObjects()
        
        do {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            guard let url = urls.first else {
                throw AppError.appConfigLoadError
            }
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            for file in files {
                try FileManager.default.removeItem(at: file)
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    func printStats() {
    }
}
