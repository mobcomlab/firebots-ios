//
//  UIImage+Crop.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 6/14/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import UIKit

extension UIImage {
    func crop() -> UIImage {
        var size: CGSize!
        if self.size.width <= self.size.height {
            size = CGSize(width: self.size.width, height: self.size.width)
        }
        else {
            size = CGSize(width: self.size.height, height: self.size.height)
        }
        let origin = CGPoint(x: (self.size.width - size.width)/2, y: (self.size.height - size.height)/2)
        
        var rect = CGRect(origin: origin, size: size)
        rect.origin.x*=self.scale
        rect.origin.y*=self.scale
        rect.size.width*=self.scale
        rect.size.height*=self.scale
        
        let imageRef = self.cgImage!.cropping(to: rect)
        let image = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        return image
    }
}
