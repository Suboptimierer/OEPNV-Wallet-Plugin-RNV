//
//  Timestamp.swift
//  OEPNV-Wallet-Plugin-RNV
//
//  Created by Jonas Sannewald on 07.04.25.
//

import Foundation

struct Timestamp {
    
    private init() {}
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss 'GMT'"
        return formatter
    }()
    
    static func generate() -> String {
        return formatter.string(from: Date())
    }
    
}
