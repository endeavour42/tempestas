//
//  ResizeableAsyncImage.swift
//  Tempestas
//
//  Created by endeavour42 on 13/12/2024.
//

import SwiftUI


/// ResizeableAsyncImage
///
/// resizeable and resized
/// optional shadow
/// with progress indicator
/// debugFrame support
///
struct ResizeableAsyncImage: View {
    let url: URL?
    let size: CGSize
    var shadowColor: Color = .clear
    var shadowRadius: CGFloat = 0
    var debugViewOptions: DebugViewOptions

    var body: some View {
        if let url {
            AsyncImage(
                url: url,
                content: { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: size.width, height: size.height)
                        .shadow(color: shadowColor, radius: shadowRadius) // for a better visibility of a gray cloud on a gray background
                        .debugFrame(debugViewOptions.showFrames)
                },
                placeholder: {
                    ProgressView()
                        .debugFrame(debugViewOptions.showFrames)
                        .frame(width: size.width, height: size.height)
                        .debugFrame(debugViewOptions.showFrames)
                }
            )
            .debugFrame(debugViewOptions.showFrames)
        } else {
            Text("🤷")
                .font(.largeTitle)
                .frame(width: size.width, height: size.height)
                .debugFrame(debugViewOptions.showFrames)
        }
    }
}

