//
//  FormView.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 3/28/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import UIKit

class FormView: UIView {
    
    override func awakeFromNib() {
        Style.CardView.setup(view: self)
        layer.borderWidth = 1
        layer.borderColor = Style.Color.textFieldPanelBorder.cgColor
    }
    
    func red() {
        layer.borderWidth = 0
        layer.backgroundColor = Style.Color.red.cgColor
    }
    
}

