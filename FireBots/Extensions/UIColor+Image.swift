//
//  UIColor+Image.swift
//  ParentsHero
//
//  Created by Admin on 10/6/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit

extension UIColor {
    
//    func singlePixelImage() -> UIImage {
//        let rect: CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0)
//        self.setFill()
//        UIRectFill(rect)
//        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
//        UIGraphicsEndImageContext()
//        return image
//    }
    
    func bottomBorderImage(height: CGFloat, borderHeight: CGFloat) -> UIImage {
        let rect: CGRect = CGRect(x: 0, y: height-borderHeight, width: 1, height: borderHeight)
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: height), false, 0)
        self.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image.resizableImage(withCapInsets: UIEdgeInsets.zero)
    }
}
