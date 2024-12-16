//
//  LocationListView.swift
//  Tempestas
//
//  Created by endeavour42 on 12/12/2024.
//

import SwiftUI

struct LocationListView: View {
    @State private var searchText: String = ""
    @State private var presentingSearch = false
    
//    @EnvironmentObject private var model: TempestasModel     // MARK: Observation variant: ObservableObject
    @Environment(TempestasModel.self) private var model        // MARK: Observation variant: Observable

    private let debugMockName = "mockLocationListView.jpg"
    
    var body: some View {
        NavigationStack {
            List {
                if presentingSearch {
                    ForEach(model.searchResults) { searchResult in
                        Button(searchResult.fullName) {
                            presentingSearch = false
                            model.startAddingNewLocation(searchResult)
                        }
                    }
                } else {
                    Section {
                        // Current location
                        LocationItemView(favourite: model.currentFavourite)
                    } header: {
                        Text("Favourites")
                            .style(model.style.locationListFavourites)
                    }
                    
                    Section {
                        // Other locations
                        ForEach(model.state.favourites) { favourite in
                            LocationItemView(favourite: favourite)
                        }
                        .onMove { indexSet, offset in
                            model.state.favourites.move(fromOffsets: indexSet, toOffset: offset)
                        }
                        .onDelete { indexSet in
                            model.state.favourites.remove(atOffsets: indexSet)
                        }
                    }
                }
            }
            //.listRowSpacing(-6)
            .listStyle(PlainListStyle())
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { EditButton() }
            .background(Color.secondaryBackground)
            .padding(model.layoutAdjustments.locationList)
            .searchable(text: $searchText, isPresented: $presentingSearch, prompt: "Search for a city or airport")
            .onSubmit(of: .search) {
                model.search(string: searchText)
                searchText = ""
            }
            .onAppear { model.debugShowMock(debugMockName) }
            .onDisappear { model.debugHideMock(debugMockName) }
        }
        .padding(model.layoutAdjustments.locationListNavBar)
        
        .sheet(isPresented: model.addingNewFavouriteBinding) {
            NavigationStack {
                if let location = model.newFavourite?.searchResult.location {
                    LocationDetailView(location: location)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Cancel") {
                                    model.cancelAddingNewLocation()
                                }
                            }
                            ToolbarItem(placement: .primaryAction) {
                                Button("Add") {
                                    model.completeAddingNewLocation()
                                }
                            }
                        }
                }
            }
        }
    }
}

private struct LocationItemView: View {
    let favourite: Favourite?
    
//    @EnvironmentObject private var model: TempestasModel     // MARK: Observation variant: ObservableObject
    @Environment(TempestasModel.self) private var model        // MARK: Observation variant: Observable

    var body: some View {
        
        ZStack(alignment: .leading) {
            // TODO: this is a roundabout way to hide disclosure triangle. Once there's a better way fix this.
            NavigationLink(destination: TabbedLocationDetailView(location: favourite?.id)) {
                EmptyView()
            }.opacity(0)
            
            locationContentView()
        }
        .debugFrame(model.debugViewOptions.showFrames)
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private func locationContentView() -> some View {
        ZStack {
            Color.tertiaryBackground
            VStack {
                Spacer()
                HStack {
                    leftView()
                    Spacer()
                    rightView()
                }
                Spacer()
            }
        }
        .frame(height: 123)
        .cornerRadius(16)
    }
    
    private func leftView() -> some View {
        let iconCode = favourite?.weatherInfo?.current.weather.first?.icon
        let timeZoneOffset = favourite?.weatherInfo?.timezone_offset ?? 0
        var string = Date().timeString(timeZoneOffset: timeZoneOffset)
        if (favourite?.location.isCurrentLocation ?? false), let name = favourite?.searchResult.currentLocationPlace {
            string = name
        }

        return HStack(spacing: 3) {
            WeatherIcon(iconCode: iconCode, size: CGSize(width: 100, height: 100), debugViewOptions: model.debugViewOptions)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(favourite?.searchResult.shortName ?? "?")
                    .style(model.style.locationListLocation1)
                Text(string)
                    .style(model.style.locationListTime)
            }
        }
    }
    
    private func rightView() -> some View {
        let temp = favourite?.weatherInfo?.current.temp
        
        return VStack(alignment: .trailing) {
            if let favourite, favourite.searchResult.name == nil && favourite.searchResult.lat == nil && !model.locationServicesAuthorized {
                Button {
                    model.requestLocationAuthorization()
                } label: {
                    Image(systemName: "location.circle.fill")
                        .style(model.style.locationListRequestLocation)
                }
                .frame(width: 50, height: 50)
            } else {
                VStack {
                    Spacer()
                    Text(temp?.asTemperature().string ?? "--")
                        .style(temp != nil ? model.style.locationListTemperature : model.style.locationListTemperatureNA)
                    Spacer()
                    if let weatherCondition = favourite?.weatherInfo?.current.weather.first?.main {
                        Text(weatherCondition)
                            .style(model.style.locationListWeatherCondition)
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .offset(model.layoutAdjustments.locationListTemperature)
    }
}

struct WeatherIcon: View {
    let iconCode: String?
    let size: CGSize
    let debugViewOptions: DebugViewOptions

    var body: some View {
        ResizeableAsyncImage(
            url: OWM.urlForIcon(iconCode: iconCode),
            size: size,
            shadowColor: .primary,
            shadowRadius: 1,
            debugViewOptions: debugViewOptions
        )
    }
}
