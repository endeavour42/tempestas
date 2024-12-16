//
//  Temperature_Extensions.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import Foundation

typealias Temperature = Measurement<UnitTemperature>

extension Temperature {
    /// Handy initialiser
    init?(_ value: Double?, _ unit: UnitTemperature) {
        guard let value else { return nil }
        self.init(value: value, unit: unit)
    }
}

extension Temperature {
    var string: String {
        let formatter = MeasurementFormatter()
        formatter.numberFormatter.maximumFractionDigits = 0
        formatter.unitStyle = .short
        return formatter.string(from: self)
    }
}

