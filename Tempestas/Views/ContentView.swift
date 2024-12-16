//
//  ContentView.swift
//  Tempestas
//
//  Created by endeavour42 on 16/12/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            LocationListView()
            MockView()
            DebugView()
        }
//        .environmentObject(TempestasModel.shared)            // MARK: Observation variant: ObservableObject
        .environment(TempestasModel.shared)                    // MARK: Observation variant: Observable
    }
}

#Preview {
    ContentView()
}
