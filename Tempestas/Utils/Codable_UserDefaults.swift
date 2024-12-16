//
//  Codable_UserDefaults.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import Foundation

enum UserDefaultsError: Error { case notFound }

extension Encodable {
    func saveJson(_ key: String, _ defaults: UserDefaults = .standard) throws {
        try defaults.set(jsonData(), forKey: key)
    }
    func removeJson(_ key: String, _ defaults: UserDefaults = .standard) {
        defaults.removeObject(forKey: key)
    }
}

extension Decodable {
    init(loadJson key: String, _ defaults: UserDefaults = .standard) throws {
        guard let data = defaults.data(forKey: key) else {
            print("••• no data found for \(key)")
            throw UserDefaultsError.notFound
        }
        try self.init(jsonData: data)
    }
}
