//
//  Button.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 3/28/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import UIKit

class Button: UIButton {
    
    //MARK: Initializers
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        layer.cornerRadius = 5.0
        layer.borderWidth = 3
        disable()
    }
    
    func red() {
        isEnabled = true
        layer.backgroundColor = nil
        layer.borderWidth = 0
        titleLabel!.textColor = Style.Color.red
    }
    
    func enable() {
        isEnabled = true
        backgroundColor = Style.Color.buttonEnableBackground
        layer.borderColor = Style.Color.buttonEnableBorder.cgColor
    }
    
    func disable() {
        isEnabled = false
        backgroundColor = Style.Color.buttonDisableBackground
        layer.borderColor = Style.Color.buttonDisableBorder.cgColor
    }
    
}
