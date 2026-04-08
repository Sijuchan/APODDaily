//
//  APODDateFormatter.swift
//  APODDaily
//
//  Created by Siju Satheesachandran on 08/04/2026.
//

import Foundation

enum APODDateFormatter {

    private static let formatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        format.locale = Locale(identifier: "en_US_POSIX")
        format.timeZone = TimeZone(secondsFromGMT: 0)
        return format
    }()

    static func parse(_ string: String) -> Date {
        formatter.date(from: string) ?? .now
    }

    static func format(_ date: Date) -> String {
        formatter.string(from: date)
    }
}
