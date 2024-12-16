//
//  DebugFrameModifier.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import SwiftUI

private let debugFrameColor: Color = Color(red: 0.9, green: 0, blue: 0.8).opacity(0.7)
private let debugFrameWidth: CGFloat = 2

struct DebugFrameModifier: ViewModifier {
    let show: Bool
    let color: Color
    let width: CGFloat

    func body(content: Content) -> some View {
        content.border(show ? color : .clear, width: show ? width : 0)
    }
}

extension View {
    func debugFrame(_ show: Bool, borderColor: Color? = nil, borderWidth: CGFloat? = nil) -> some View {
        modifier(DebugFrameModifier(show: show, color: borderColor ?? debugFrameColor, width: borderWidth ?? debugFrameWidth))
    }
}

