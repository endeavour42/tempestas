//
//  TempestasModel_Style.swift
//  Tempestas
//
//  Created by endeavour42 on 14/12/2024.
//

import SwiftUI

/// ViewStyle
extension TempestasModel {
    
    var style: Style { Style(debugViewOptions: debugViewOptions) }
    
    struct Style {
        let debugViewOptions: DebugViewOptions

        var locationListWeatherCondition: ViewStyle { ViewStyle(.caption.weight(.semibold), .primary, debugViewOptions) }
        var locationListLocation1: ViewStyle        { ViewStyle(.title3.bold(), .primary, debugViewOptions) }
        var locationListTime: ViewStyle             { ViewStyle(.subheadline, .secondary, debugViewOptions) }
        var locationListFavourites: ViewStyle       { ViewStyle(.title3.bold(), .primary, debugViewOptions) }
        var locationListTemperature: ViewStyle      { ViewStyle(listTemperatureFont, .primary, debugViewOptions) }
        var locationListTemperatureNA: ViewStyle    { ViewStyle(listTemperatureFont, .secondary, debugViewOptions) }
        var locationListRequestLocation: ViewStyle  { ViewStyle(.largeTitle, .accentColor, DebugViewOptions()) }

        var detailViewHighLowArrows: ViewStyle      { ViewStyle(.title2.bold(), .primary, debugViewOptions) }
        var detailViewHighLowTemperature: ViewStyle { ViewStyle(.title.weight(.medium), .primary, debugViewOptions) }
        var detailViewhHighLowLabels: ViewStyle     { ViewStyle(.subheadline.weight(.medium), .secondary, debugViewOptions) }
        var detailViewForecastHeader: ViewStyle     { ViewStyle(.title3.bold(), .primary, debugViewOptions) }
        var detailViewTemperature: ViewStyle        { ViewStyle(temperatureFont, .primary, debugViewOptions) }
        var detailViewSubtitle: ViewStyle           { ViewStyle(.subheadline, .secondary, debugViewOptions) }
        
        var dayThumbWeekday: ViewStyle              { ViewStyle(.caption.bold(), .primary, debugViewOptions) }
        var dayThumbTemperature: ViewStyle          { ViewStyle(.title.bold(), .primary, debugViewOptions) }
        
        var debugDisclosureButton: ViewStyle        { ViewStyle(.largeTitle, .accentColor, DebugViewOptions()) }
        var debugButtons: ViewStyle                 { ViewStyle(.caption2, .secondaryBackground, DebugViewOptions()) }

        private var temperatureFont: Font {
            if debugViewOptions.layoutAdjustments {
                let uiFont = UIFont.preferredFont(forTextStyle: .largeTitle)
                let textSize = round(uiFont.pointSize * 1.82)
                return .system(size: textSize, weight: .semibold, design: .default)
            } else {
                return .largeTitle.bold()
            }
        }
        
        private var listTemperatureFont: Font {
            if debugViewOptions.layoutAdjustments {
                let uiFont = UIFont.preferredFont(forTextStyle: .largeTitle)
                let textSize = round(uiFont.pointSize * 1.4)
                return .system(size: textSize, weight: .semibold, design: .default)
            } else {
                return .largeTitle.bold()
            }
        }
    }
}
