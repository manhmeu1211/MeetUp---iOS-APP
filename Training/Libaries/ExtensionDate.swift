//
//  DateTimeFormatterService.swift
//  Training
//
//  Created by ManhLD on 12/11/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import UIKit

extension Date {
    
    enum StyleDate: String {

        case dayAndDate = "EEEE, MMM d, yyyy"
        case dateOnly = "yyyy/MM/dd"
        case hourOnly = "HH:mm a"
        case dateAndHour = "yyyy/MM/dd HH:mm"
        case dateAndTime = "yyyy/MM/dd HH:mm:ss"
        case full = "EEE yyyy/MM/dd HH:mm"
        case fullTime = "EEE yyyy/MM/dd HH:mm:ss"
        case dayMonthYear = "dd/MM/yyyy"
        case yearMonth = "yyyy-MM"
        case dateOnlyFromServer = "yyyy-MM-dd"
        case dateTime = "dd/MM/yyyy HH:mm"
        case dateTimeFromServer = "yyyy-MM-dd HH:mm:ss"
        case dateHourMinuteServer = "yyyy-MM-dd HH:mm"
        case monthYear = "MM/yyyy"
        case timeOnly = "HH:mm"
        case ggFull = "yyyy-MM-dd'T'HH:mm:ssZ"
        case concurrenceEvent = "yyyyMMdd'T'HHmmssZ"
    }
    
    func convertDateToString(formatter: Date.StyleDate, date : Date) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter.rawValue
        dateFormatter.locale = Locale(identifier: "locale".localized)
        let dateString = dateFormatter.string(from: date)
        return dateString
    }
    
    func converStringToDate(formatter : Date.StyleDate, dateString : String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter.rawValue
        let date = dateFormatter.date(from: dateString)
        return date
    }
}

extension DateFormatter {
    
}

extension NSDate {
     var formatted: String {
     let formatter = DateFormatter()
     formatter.dateFormat = "MM/dd/yyyy"
         return formatter.string(from: self as Date)
     }
 }
