//
//  ViewStyleModifier.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import SwiftUI

struct ViewStyleModifier: ViewModifier {
    let style: ViewStyle
    
    func body(content: Content) -> some View {
        let options = style.debugViewOptions
        
        return content
            .font(style.font)
            .foregroundStyle(options.showInRed ? .red : style.color)
            .debugFrame(options.showFrames)
    }
}

struct ViewStyle {
    let font: Font
    let color: Color
    let debugViewOptions: DebugViewOptions
    
    init(_ font: Font, _ color: Color, _ debugViewOptions: DebugViewOptions) {
        self.font = font
        self.color = color
        self.debugViewOptions = debugViewOptions
    }
}

extension View {
    func style(_ style: ViewStyle) -> some View {
        modifier(ViewStyleModifier(style: style))
    }
}


