//
//  Misc_Extensions.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import SwiftUI

extension CGSize {
    var ratio: CGFloat { height / width }
}

extension EdgeInsets {
    static let zero = EdgeInsets()
}

extension Double {
    func asTemperature(unit: UnitTemperature = .kelvin) -> Temperature {
        Temperature(value: self, unit: unit)
    }
    func asDate() -> Date {
        Date(timeIntervalSince1970: self)
    }
}

extension Int {
    func asDate() -> Date {
        Double(self).asDate()
    }
}

func resourceData(named name: String) -> Data? {
    guard let url = Bundle.main.url(forResource: name, withExtension: nil) else {
        print("••• no file named \(name)")
        return nil
    }
    do {
        return try Data(contentsOf: url)
    } catch {
        print("••• data loading error \(error), name: \(name)")
        return nil
    }
}

extension Color {
    static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
    static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
}

extension Image {
    init?(named name: String) {
        guard let image = UIImage(named: name) else {
            print("••• no image named \(name)")
            return nil
        }
        self.init(uiImage: image)
    }
}
