//
//  DayThumbnailList.swift
//  Tempestas
//
//  Created by endeavour42 on 13/12/2024.
//

import SwiftUI

struct DayThumbnailList: View {
    let weatherInfo: WeatherInfo
    @Binding var selectedDay: Int?
//    @EnvironmentObject private var model: TempestasModel     // MARK: Observation variant: ObservableObject
    @Environment(TempestasModel.self) private var model        // MARK: Observation variant: Observable

    var body: some View {
        let timeZoneOffset = weatherInfo.timezone_offset
        
        if let days = weatherInfo.daily {
            ScrollView(.horizontal) {
                LazyHStack(spacing: 16) {
                    ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                        Button {
                            withAnimation {
                                selectedDay = selectedDay == index ? nil : index
                            }
                        } label: {
                            DayThumbnailView(item: day, timeZoneOffset: timeZoneOffset, selected: selectedDay == index)
                        }
                    }
                }
            }
            .frame(height: 165)
            .contentMargins(.horizontal, 16)
            .offset(model.layoutAdjustments.dayThumbList)
        }
    }
}

private struct DayThumbnailView: View {
    let item: Daily
    let timeZoneOffset: Int
    let selected: Bool
//    @EnvironmentObject private var model: TempestasModel     // MARK: Observation variant: ObservableObject
    @Environment(TempestasModel.self) private var model        // MARK: Observation variant: Observable

    private let thumbnailSize = CGSize(width: 116, height: 165)
    private let iconSize = CGSize(width: 100, height: 100)
    
    var body: some View {
        ZStack {
            (selected ? Color.gray.opacity(0.5) : Color.secondaryBackground)
                .cornerRadius(16)
                .debugFrame(model.debugViewOptions.showFrames)
            
            VStack {
                HStack {
                    Text(item.dt.asDate().weekdayString(timeZoneOffset: timeZoneOffset))
                        .style(model.style.dayThumbWeekday)
                    Spacer()
                }
                .padding()
                .offset(model.layoutAdjustments.dayThumbWeekdayLabel)
                
                Spacer()
            }
            
            WeatherIcon(iconCode: item.iconCode, size: iconSize, debugViewOptions: model.debugViewOptions)
                .padding(.bottom)
                .offset(model.layoutAdjustments.dayThumbIcon)
            
            VStack {
                Spacer()
                
                Text(item.temp.day.asTemperature().string)
                    .style(model.style.dayThumbTemperature)
                    .padding()
                    .offset(model.layoutAdjustments.dayThumbTemperature)
            }
        }
        .frame(width: thumbnailSize.width, height: thumbnailSize.height)
    }
}
