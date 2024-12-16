//
//  TempestasModel_LayoutAdjustments.swift
//  Tempestas
//
//  Created by endeavour42 on 14/12/2024.
//

import SwiftUI

// Small layout adjustments
//
// Ideally we should not have any layout-related constants in code, default padding/spacing
// should work in most cases. In practice we need to match desired UI screens and on top of
// that do some minor adjustments to match provided UI's closely (ideally pixel perfectly).
// Below is a set of those small adjustments, you could toggle the `pixel ~perfect` switch
// to see the results with and without those adjustments.

// Note: the weather icons are taken from the weather provider server and they don't
// match provided mock screens. On top of that those icons don't look quite alright on gray
// background so I've added a small shadow effect for visual appeal.

/// LayoutAdjustments
extension TempestasModel {
    var layoutAdjustments: LayoutAdjustments { LayoutAdjustments(debugViewOptions: debugViewOptions) }
    
    struct LayoutAdjustments {
        let debugViewOptions: DebugViewOptions
        
        private func enabled() -> CGSize?       { !debugViewOptions.layoutAdjustments ? .zero : nil }
        private func enabled() -> EdgeInsets?   { !debugViewOptions.layoutAdjustments ? .zero : nil }

        var locationListTemperature: CGSize     { enabled() ?? CGSize(width: -2, height: 0) }
        var locationListNavBar: EdgeInsets      { enabled() ?? EdgeInsets(top: -23, leading: 0, bottom: 0, trailing: 0) }
        var locationList: EdgeInsets            { enabled() ?? EdgeInsets(top: -2, leading: -4, bottom: -2, trailing: -4) }
        
        var detailViewTemperature: CGSize       { enabled() ?? CGSize(width: -4, height: -7) }
        var detailViewHighLowBar: CGSize        { enabled() ?? CGSize(width: -2, height: 0) }
        var detailViewLowLabel: CGSize          { enabled() ?? CGSize(width: 4, height: 0) }
        var detailViewForecastHeader: CGSize    { enabled() ?? CGSize(width: 0, height: 1) }
        var detailViewDivider: EdgeInsets       { enabled() ?? EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0) }

        var dayThumbList: CGSize                { enabled() ?? CGSize(width: 1, height: 0) }
        var dayThumbWeekdayLabel: CGSize        { enabled() ?? CGSize(width: -3, height: -4) }
        var dayThumbIcon: CGSize                { enabled() ?? CGSize(width: 0, height: -6) }
        var dayThumbTemperature: CGSize         { enabled() ?? CGSize(width: 1, height: -2) }
    }
}
