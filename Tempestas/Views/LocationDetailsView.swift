//
//  LocationDetailView.swift
//  Tempestas
//
//  Created by endeavour42 on 12/12/2024.
//

import SwiftUI

struct TabbedLocationDetailView: View {
    @State var location: Location?
    private let debugMockName = "mockLocationDetailView.jpg"
    
//    @EnvironmentObject private var model: TempestasModel     // MARK: Observation variant: ObservableObject
    @Environment(TempestasModel.self) private var model        // MARK: Observation variant: Observable

    var body: some View {
        TabView(selection: $location) {
            ForEach(model.favourites(includeCurrent: true, includeNew: false)) { favourite in
                LocationDetailView(location: favourite.id)
                    .tag(favourite.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onAppear { model.debugShowMock(debugMockName) }
        .onDisappear { model.debugHideMock(debugMockName) }
        .toolbarRole(ToolbarRole.editor) // removes back button title
    }
}

struct LocationDetailView: View {
    let location: Location
    @State private var searchText: String = ""
    @State private var selectedDay: Int?
//    @EnvironmentObject private var model: TempestasModel     // MARK: Observation variant: ObservableObject
    @Environment(TempestasModel.self) private var model        // MARK: Observation variant: Observable

    private let iconSize = CGSize(width: 200, height: 200)
    
    var body: some View {
        let debugViewOptions = model.debugViewOptions
        let favourite = model.findAnyFavourite(location)
        let weatherInfo = favourite?.weatherInfo
        
        if let favourite {
            ZStack {
                VStack {
                    VStack(spacing: 0) {
                        let iconCode = iconCode(weatherInfo: weatherInfo)
                        WeatherIcon(iconCode: iconCode, size: iconSize, debugViewOptions: debugViewOptions)
                        centerAreaView(weatherInfo)
                    }
                    Spacer()
                    if let weatherInfo {
                        forecastView(weatherInfo)
                            .padding(.bottom)
                            .padding(.bottom, debugViewOptions.layoutAdjustments ? 41 : nil)
                    }
                }
                HStack {
                    VStack(alignment: .leading) {
                        Text(subtitle(weatherInfo: weatherInfo))
                            .style(model.style.detailViewSubtitle)
                        if favourite.location.isCurrentLocation, let name = favourite.searchResult.currentLocationPlace {
                            Text(name)
                                .style(model.style.detailViewSubtitle)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            .navigationTitle(favourite.searchResult.shortName)
        }
    }
    
    private func iconCode(weatherInfo: WeatherInfo?) -> String? {
        guard let selectedDay else {
            return weatherInfo?.current.weather.first?.icon
        }
        guard let weatherInfo, let daily = weatherInfo.daily, selectedDay >= 0 && selectedDay < daily.count else {
            return nil
        }
        return daily[selectedDay].iconCode
    }
    
    private func subtitle(weatherInfo: WeatherInfo?) -> String {
        guard let selectedDay else {
            return "Now"
        }
        guard let weatherInfo, let daily = weatherInfo.daily, selectedDay >= 0 && selectedDay < daily.count else {
            return "?"
        }
        let date = daily[selectedDay].dt.asDate()
        let string = date.weekdayString(timeZoneOffset: weatherInfo.timezone_offset)
        return string
    }
    
    private func calculateMinMaxTemp(weatherInfo: WeatherInfo?) -> (minTemp: Double?, maxTemp: Double?) {
        guard let daily = weatherInfo?.daily else { return (nil, nil) }
        if let selectedDay {
            guard selectedDay >= 0 && selectedDay < daily.count else { return (nil, nil) }
            let temp = daily[selectedDay].temp
            return (temp.min, temp.max)
        } else {
            let temp = weatherInfo?.daily?.first?.temp
            return (temp?.min, temp?.max)
        }
    }
    
    private func centerAreaView(_ weatherInfo: WeatherInfo?) -> some View {
        VStack(spacing: 17) {
            Text(weatherInfo?.current.temp.asTemperature().string ?? "--")
                .style(model.style.detailViewTemperature)
                .offset(model.layoutAdjustments.detailViewTemperature)
            
            if let weatherInfo {
                let (minTemp, maxTemp) = calculateMinMaxTemp(weatherInfo: weatherInfo)
                highLowBar(minTemp: minTemp, maxTemp: maxTemp)
                    .padding(.trailing)
                    .offset(model.layoutAdjustments.detailViewHighLowBar)
            }
        }
    }
    
    private func highLowBar(minTemp: Double?, maxTemp: Double?) -> some View {
        return HStack(spacing: 15) {
            highLowComponent(high: true, temperature: maxTemp?.asTemperature())
            highLowComponent(high: false, temperature: minTemp?.asTemperature())
        }
    }

    private func highLowComponent(high: Bool, temperature: Temperature?) -> some View {
        VStack(spacing: 3) {
            HStack(spacing: 7) {
                Text(high ? "↑" : "↓")
                    .style(model.style.detailViewHighLowArrows)
                Text(temperature?.string ?? "--")
                    .style(model.style.detailViewHighLowTemperature)
            }
            
            Text(high ? "High" : "Low")
                .style(model.style.detailViewhHighLowLabels)
                .offset(high ? .zero : model.layoutAdjustments.detailViewLowLabel)
        }
    }

    private func forecastView(_ weatherInfo: WeatherInfo) -> some View {
        VStack(alignment: .leading) {
            
            Text("5 Day Forecast")
                .style(model.style.detailViewForecastHeader)
                .padding(.horizontal)
                .offset(model.layoutAdjustments.detailViewForecastHeader)

            Divider()
                .padding([.leading, .bottom])
                .padding(model.layoutAdjustments.detailViewDivider)

            DayThumbnailList(weatherInfo: weatherInfo, selectedDay: $selectedDay)
        }
    }
}
