//
//  PaddingLabel.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 5/3/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets.init(top: 8, left: 8, bottom: 8, right: 8)
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
}
