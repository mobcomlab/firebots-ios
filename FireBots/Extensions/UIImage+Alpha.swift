//
//  UIImage+Alpha.swift
//  ParentsHero
//
//  Created by Admin on 10/6/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit

extension UIImage {
    
    func imageWithAlpha(alpha: CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        
        if let ctx = UIGraphicsGetCurrentContext() {
            
            let area: CGRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
            ctx.scaleBy(x: 1, y: -1)
            ctx.translateBy(x: 0, y: -area.size.height)
            ctx.setBlendMode(.multiply)
            ctx.setAlpha(alpha)
            ctx.draw(self.cgImage!, in: area)
            let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            return newImage
        }
        
        assertionFailure("Couldn't get CGContext")
        return self
    }
}
