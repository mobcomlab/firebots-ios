//
//  TextField.swift
//  ParentsHero
//
//  Created by Admin on 10/20/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit

class TextField: UITextField, UITextFieldDelegate {
    
    let padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
}
