//
//  MockView.swift
//  Tempestas
//
//  Created by endeavour42 on 14/12/2024.
//

import SwiftUI

struct MockView: View {
//    @EnvironmentObject private var model: TempestasModel     // MARK: Observation variant: ObservableObject
    @Environment(TempestasModel.self) private var model        // MARK: Observation variant: Observable

    var body: some View {
        if let name = model.debugViewOptions.mockFileName, let image = Image(named: name) {
            image
                .resizable()
            //                .scaledToFill()
            //                .aspectRatio(contentMode: .fill)
                .frame(width: 780/2, height: 1688/2)
                .ignoresSafeArea()
                .allowsHitTesting(false)
                .opacity(model.debugViewOptions.showMock ? 0.5 : 0)
        }
    }
}
