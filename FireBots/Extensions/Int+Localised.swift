//
//  Int+Localised.swift
//  ParentsHero
//
//  Created by Ant on 17/01/2017.
//  Copyright © 2017 Admin. All rights reserved.
//

import Foundation

extension Int {
    
    var localizedString: String {
        return Int.localizedNumberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    fileprivate static var localizedNumberFormatter: NumberFormatter {
        struct Static {
            static let instance: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                return formatter
            }()
        }
        return Static.instance
    }
    
}
