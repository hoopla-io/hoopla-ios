//
//  Formatter.swift
//  qahvazor-vendor
//
//  Created by Alphazet on 15/12/24.
//

import Foundation

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()
    
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
    
    var formattedWithCurrency: String {
        let price = Formatter.withSeparator.string(for: self) ?? ""
        return price + Symbols.space.rawValue + "som".localized
    }
}
