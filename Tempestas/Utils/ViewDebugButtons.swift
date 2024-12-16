//
//  DebugView.swift
//  Tempestas
//
//  Created by endeavour42 on 14/12/2024.
//

import SwiftUI

struct DebugView: View {
    @State private var showAlert = false
//    @EnvironmentObject private var model: TempestasModel     // MARK: Observation variant: ObservableObject
    @Environment(TempestasModel.self) private var model        // MARK: Observation variant: Observable
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .trailing) {
                buttonsView()
                Spacer()
            }
            .padding(EdgeInsets(top: 75, leading: 0, bottom: 0, trailing: 5))
        }
        .alert(isPresented: $showAlert) {
            let title = "Mock resolution and/or\ncolour scheme mismatch"
            let explanation = "The mock screen resolution and/or the colour scheme does not match the actual screen resolution and/or colour scheme. Please use iPhone 14 device or simulator with light mode to see the correct mock screen."
            return SwiftUI.Alert(
                title: Text(title),
                message: Text(explanation),
                primaryButton: .default(Text("OK")),
                secondaryButton: .default(Text("Don't Show Again")) {
                    model.debugViewOptions.showMockSizeMismatchWarning = false
                }
            )
        }
    }
    
    private func disclosureButton() -> some View {
        Button {
            withAnimation {
                model.debugViewOptions.showOptions.toggle()
            }
        } label: {
            Image(systemName: "ladybug")
        }
        .rotationEffect(Angle.degrees(model.debugViewOptions.showOptions ? -180 : -90))
        .style(model.style.debugDisclosureButton)
        .controlSize(.extraLarge)
        .buttonStyle(.plain)
    }
    
    private func buttonsView() -> some View {
        VStack(alignment: .trailing) {
            disclosureButton()
            if model.debugViewOptions.showOptions {
                buttonList()
            }
        }
        .style(model.style.debugButtons)
        .controlSize(.small)
        .buttonStyle(.borderedProminent)
        .padding(8)
        
        .background {
            Color.clear
                .background(.ultraThinMaterial)
                .environment(\.colorScheme, model.debugViewOptions.showOptions ? .dark : .light)
        }
        .cornerRadius(16)
    }
    
    private func buttonList() -> some View {
        VStack {
            Button("show frames") {
                withAnimation {
                    model.debugViewOptions.showFrames.toggle()
                }
            }
            .accentColor(model.debugViewOptions.showFrames ? .accentColor : .secondary)
            
            Button("show mock") {
                withAnimation {
                    model.debugViewOptions.showMock.toggle()
                    if model.debugViewOptions.showMock {
                        if model.debugViewOptions.showMockSizeMismatchWarning && (model.debugViewOptions.mockSizeMismatch || colorScheme != .light) {
                            showAlert = true
                        }
                    }
                }
            }
            .accentColor(model.debugViewOptions.showMock ? .accentColor : .secondary)
            
            Button("show in red") {
                withAnimation {
                    model.debugViewOptions.showInRed.toggle()
                }
            }
            .accentColor(model.debugViewOptions.showInRed ? .accentColor : .secondary)
            
            Button("pixel ~perfect") {
                withAnimation {
                    model.debugViewOptions.layoutAdjustments.toggle()
                    if model.debugViewOptions.showMock && model.debugViewOptions.layoutAdjustments {
                        if model.debugViewOptions.showMockSizeMismatchWarning && (model.debugViewOptions.mockSizeMismatch || colorScheme != .light) {
                            showAlert = true
                        }
                    }
                }
            }
            .accentColor(model.debugViewOptions.layoutAdjustments ? .accentColor : .secondary)
            
            Button("reset settings") {
                withAnimation {
                    model.resetSettings()
                }
            }
            .accentColor(.red)
        }
    }
}
