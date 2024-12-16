//
//  DebugViewOptions.swift
//  Tempestas
//
//  Created by endeavour42 on 14/12/2024.
//

import Foundation

struct DebugViewOptions: Codable {
    static let name = "debugViewOptions"
    
    var showOptions = false
    var showFrames = false
    var showMock = false
    var showInRed = false
    var layoutAdjustments = true
    var showMockSizeMismatchWarning = true
    var mockSizeMismatch = false
    
    var mockFileName: String?
}
