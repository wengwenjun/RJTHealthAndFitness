//
//  DateFormatter+Ext.swift
//  Budget Pig
//
//  Created by Ron Ramirez on 9/12/16.
//  Copyright © 2016 Mochi Apps. All rights reserved.
//

import Foundation


extension Date {
    
    func MonthDayDateFormatter() -> String {
        return DateFormatter.MonthDayDateFormatter.string(from: self)
    }
    
    func DayDateFormatter() -> String {
        return DateFormatter.DayDateFormatter.string(from: self)
    }
    func MonthDateFormatter() -> String {
        return DateFormatter.MonthDateFormatter.string(from: self)
    }
    
    
}

// Formatter for Short-Style Date E.G. 10/11/2016 3:11 P.M
extension DateFormatter {
    
    fileprivate static let MonthDayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, YYYY"
        return formatter
    }()
    
    fileprivate static let DayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = " EEEE"
        return formatter
    }()
    
    fileprivate static let MonthDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }()
    
}



