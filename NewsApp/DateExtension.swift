//
//  DateExtension.swift
//  NewsApp
//
//  Created by Victor on 3/31/21.
//

import Foundation

extension Date {
    static func numberOfDaysBefore(number: Int) -> Date {
        let currentDate = Date()
        return Calendar.current.date(byAdding: .day, value: -number, to: currentDate)!
    }
    
    func numberOfHoursBefore(number: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: -number, to: self)!
    }
    
    static func -(recent: Date, previous: Date) -> String? {
        let day = Calendar.current.dateComponents([.day], from: previous, to: recent).day
        if let day = day {
            if day != 0 {
                return "\(day)d"
            }
        }
        let hour = Calendar.current.dateComponents([.hour], from: previous, to: recent).hour
        if let hour = hour {
            if hour != 0 {
                return "\(hour)h"
            }
        }
        let minute = Calendar.current.dateComponents([.minute], from: previous, to: recent).minute
        if let minute = minute {
            if minute != 0 {
                return "\(minute)m"
            }
        }
        return nil
    }
}
