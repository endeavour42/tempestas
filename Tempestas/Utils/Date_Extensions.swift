//
//  Date_Extensions.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import Foundation

extension Date {
    func timeString(timeZoneOffset: Int) -> String {
        let timeZone = TimeZone(secondsFromGMT: timeZoneOffset) ?? .current
        let dateStyle = Date.FormatStyle(date: .omitted, time: .shortened, timeZone: timeZone)
        return formatted(dateStyle)
    }

    func weekdayString(timeZoneOffset: Int) -> String {
        var formatter = Date.FormatStyle.dateTime.weekday(.abbreviated)
        formatter.timeZone = TimeZone(secondsFromGMT: timeZoneOffset) ?? .current
        let result = formatted(formatter)
        return result
    }
}
