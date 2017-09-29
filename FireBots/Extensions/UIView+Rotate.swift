//
//  UIView+Rotate.swift
//  ParentsHero
//
//  Created by Admin on 10/7/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit

extension UIView {
    
    func rotate(toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}
