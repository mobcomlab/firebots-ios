//
//  Date+Localized.swift
//  ParentsHero
//
//  Created by Ant on 18/12/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

extension Date {
    
    var localizedDateString: String {
        return Date.localizedDateFormatter.string(from: self)
    }
    
    fileprivate static var localizedDateFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                if dateFormatter.calendar.identifier == Calendar.Identifier.buddhist {
                    dateFormatter.dateFormat = "dd MMM yyyy"
                }
                return dateFormatter
            }()
        }
        return Static.instance
    }

    var birthdayString: String {
        return Date.birthdayFormatter.string(from: self)
    }
    
    fileprivate static var birthdayFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .medium
                dateFormatter.timeStyle = .none
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                return dateFormatter
            }()
        }
        return Static.instance
    }    
}
