//
//  Date+ISO.swift
//  ParentsHero
//
//  Created by Ant on 18/12/2016.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation

extension Date {
    
    public init?(iso8601: String) {
        guard let date = Date.iso8601DateFormatter.date(from: iso8601) else {
            return nil
        }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    var iso8601DateString: String {
        return Date.iso8601DateFormatter.string(from: self)
    }
    
    fileprivate static var iso8601DateFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                dateFormatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
                return dateFormatter
            }()
        }
        return Static.instance
    }
    
}

extension Date {
    
    public init?(legacy: String) {
        guard let date = Date.legacyDateFormatter.date(from: legacy) else {
            return nil
        }
        self.init(timeIntervalSince1970: date.timeIntervalSince1970)
    }
    
    fileprivate static var legacyDateFormatter: DateFormatter {
        struct Static {
            static let instance: DateFormatter = {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy/MM/dd"
                dateFormatter.timeZone = TimeZone(identifier: "UTC")
                return dateFormatter
            }()
        }
        return Static.instance
    }
    
}
