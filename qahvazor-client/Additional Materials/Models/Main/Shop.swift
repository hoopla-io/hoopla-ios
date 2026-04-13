//
//  Shop.swift
//  qahvazor-client
//
//  Created by Alphazet on 07/01/25.
//

import Foundation

struct Shop: Codable {
    let id: Int?
    let shopId: Int?
    let name: String?
    let distance: Double?
    let location: Location?
    let phoneNumbers: [PhoneNumber]?
    let pictureUrl: String?
    let pictures: [Pictures]?
    let workingHours: [WorkHour]?
    let urls: [SocialMedia]?
    let drinks: [Drinks]?
    let canAcceptOrders: Bool?
    let categories: [Categories]?
}

struct Location: Codable {
    let lat: Double?
    let lng: Double?
}

struct PhoneNumber: Codable {
    let phoneNumber: String?
}

struct Pictures: Codable {
    let pictureUrl: String?
}

struct WorkHour: Codable {
    let closeAt: String?
    let openAt: String?
    let weekDay: String?
    
    func isOpen(at date: Date = Date()) -> Bool {
        guard let openAt, let closeAt else { return false }
        guard let openMinutes  = Self.minutesSinceMidnight(openAt),
              let closeMinutes = Self.minutesSinceMidnight(closeAt) else {
            return false
        }
        
        // Same time edge case: treat as 24/7. Change to `return false` if you mean “closed”.
        if openMinutes == closeMinutes { return true }
        
        let calendar = Calendar(identifier: .gregorian)
        var cal = calendar
        cal.timeZone = .current
        
        let comps = cal.dateComponents([.hour, .minute], from: date)
        let nowMinutes = (comps.hour ?? 0) * 60 + (comps.minute ?? 0)
        
        if openMinutes < closeMinutes {
            // Normal same-day window, e.g. 09:00–23:00
            return nowMinutes >= openMinutes && nowMinutes < closeMinutes
        } else {
            // Overnight window, e.g. 22:00–06:00
            return nowMinutes >= openMinutes || nowMinutes < closeMinutes
        }
    }
    
    // MARK: - Helpers
    private static func minutesSinceMidnight(_ hhmm: String) -> Int? {
        let parts = hhmm.split(separator: ":")
        guard parts.count == 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]),
              (0..<24).contains(h), (0..<60).contains(m) else { return nil }
        return h * 60 + m
    }
}

struct ConfirmDrink: Codable {
    let modifications: Modifications?
}

