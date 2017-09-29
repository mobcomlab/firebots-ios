//
//  UIImageView+Download.swift
//  ParentsHero
//
//  Created by Admin on 10/19/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit
import FirebaseStorage

extension UIImageView {
    
    func downloadedFrom(_ link: String) {
        guard let url = URL(string: link) else {
            return
        }
        downloadedFrom(url: url)
    }
    
    func downloadedFrom(url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    return
            }
            DispatchQueue.main.async(execute: {
                self.image = image
            })
        }).resume()
    }
    
    @available(*, unavailable, message: "Replace with setImage(storageReference:) from FIRStorageCache which supports caching of images.")
    func downloadedFrom(storageReference: StorageReference) {
        storageReference.downloadURL(completion: { (url, error) in
            
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            
            self.downloadedFrom(url: url!)
        })
    }
}

