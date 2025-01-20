//
//  DateFormatter.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

extension DateFormatter {
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let birthDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let streamDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM, HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let timeInHour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let weekDaysWithMonth: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE. d MMM"
        formatter.locale = Locale(identifier: UserDefaults.standard.getLocalization())
        return formatter
    }()
    
    static let weekDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "eeee"
        formatter.locale = Locale(identifier: AppLanguage.en.rawValue)
        return formatter
    }()
    
    static let historyDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
}

extension DateFormatter {
    static func string(timestamp: Int? = nil, formatter: DateFormatter) -> String {
        guard let timestamp = timestamp else {
            return formatter.string(from: Date())
        }

        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        return formatter.string(from: date)
    }
}
