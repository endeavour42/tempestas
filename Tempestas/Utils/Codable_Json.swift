//
//  Codable_Json.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import Foundation

extension Encodable {
    func jsonData(formatting: JSONEncoder.OutputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = formatting
        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            print("••• JSONEncoding error: \(error)")
            throw error
        }
    }
}

extension Decodable {
    init(jsonData: Data) throws {
        let decoder = JSONDecoder()
        do {
            let value = try decoder.decode(Self.self, from: jsonData)
            self = value
        } catch {
            print("••• JSON: \(String(data: jsonData, encoding: .utf8))")
            print("••• JSONDecoding error: \(error)")
            throw error
        }
    }
}
