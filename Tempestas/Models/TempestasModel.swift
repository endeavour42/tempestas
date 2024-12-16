//
//  TempestasModel.swift
//  Tempestas
//
//  Created by endeavour42 on 12/12/2024.
//

import SwiftUI
import CoreLocation

typealias Location = OWM.Location
typealias Favourite = OWM.Favourite
typealias SearchResult = OWM.SearchResult
typealias WeatherInfo = OWM.WeatherInfo
typealias Daily = OWM.Daily

extension TempestasModel {
    static let clockUpdateTimerInterval = 60.0
    static let weatherUpdateTimerInterval = 120.0
}

// Making this an NSObject subclass for CLLocationManagerDelegate

//extension TempestasModel: ObservableObject {}             // MARK: Observation variant: ObservableObject
@Observable                                                 // MARK: Observation variant: Observable
class TempestasModel: NSObject {
    
    // TODO: there's an open issue with this class getting initialized more than once when using Obserbavle instead of ObservableObject so let's use a singleton for now, this works with both Observable and ObservableObject.
    
    static let shared = TempestasModel()
    
    // main state. for now contains just favourites.
    struct State {
        var favourites: [Favourite] = []
    }
    
    // main state. for now contains just favourites.
//    @Published                                            // MARK: Observation variant: ObservableObject
    var state = TempestasModel.State(favourites: loadFavourites() ?? defaultFavorites) { // logs error inside
        didSet {
            try? state.favourites.saveJson(Self.dbName) // logs error inside
        }
    }
    
    // search results
//    @Published                                            // MARK: Observation variant: ObservableObject
    var searchResults: [SearchResult] = []
    
    // pseudo "favourite" correponding to the currently adding location. The actual adding might not happen
//    @Published                                            // MARK: Observation variant: ObservableObject
    var newFavourite: Favourite?
    
    // pseudo "favourite" correponding to current location
//    @Published                                            // MARK: Observation variant: ObservableObject
    var currentFavourite = Favourite(
        searchResult: SearchResult(isCurrentLocation: true, country: "", state: ""),
        weatherInfo: nil
    )
    
    // current location services authorization combined status
//    @Published                                            // MARK: Observation variant: ObservableObject
    var locationServicesAuthorized: Bool = false {
        didSet {
            if !locationServicesAuthorized {
                currentFavourite.searchResult.lat = nil
                currentFavourite.searchResult.lon = nil
                currentFavourite.weatherInfo = nil
            }
        }
    }
    
    // debug options
//    @Published                                            // MARK: Observation variant: ObservableObject
    var debugViewOptions = (try? DebugViewOptions(loadJson: DebugViewOptions.name)) ?? DebugViewOptions() {
        didSet {
            try? debugViewOptions.saveJson(DebugViewOptions.name) // error logged inside
        }
    }
    
//    @Published                                            // MARK: Observation variant: ObservableObject
    var change = 0
    
    // location manager instance
    private var locationManager: CLLocationManager?
    private var locationUpdateStarted = false
    private var oldLocationAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    private static var inited = false
    private var weatherUpdateTimer: Timer?
    
    var addingNewFavourite = false {
        didSet {
            if !addingNewFavourite {
                newFavourite = nil
            }
        }
    }
    var addingNewFavouriteBinding: Binding<Bool> {
        .init(get: { self.addingNewFavourite }, set: { self.addingNewFavourite = $0 })
    }

    private override init() {
        precondition(!Self.inited, "should not be initialized more than once in this test")
        Self.inited = true
        super.init()
        setup()
    }
}

extension TempestasModel {
    
    private static let owmApiKey = owmApiKeyL + owmApiKeyR
    private static let dbName = "favourites-3.db"
    
    private static var defaultFavorites: [Favourite] { [] }
    private static func loadFavourites() -> [Favourite]? {
        try? [Favourite](loadJson: Self.dbName)
    }
    
    func favourites(includeCurrent: Bool, includeNew: Bool) -> [Favourite] {
        var favourites = state.favourites
        if includeNew, let newFavourite {
            favourites.insert(newFavourite, at: 0)
        }
        if includeCurrent {
            favourites.insert(currentFavourite, at: 0)
        }
        return favourites
    }
    
    private func startClockUpdateTimer() {
        // time is shown in UI, let's update it every so often
        Timer.scheduledTimer(withTimeInterval: Self.clockUpdateTimerInterval, repeats: true) { _ in
            self.change += 1 // self.objectWillChange.send()
        }
    }
    
    private func startWeatherUpdateTimer() {
        // let's update weather info if it's too old (older than weatherUpdateTimerInterval seconds)
        weatherUpdateTimer = Timer.scheduledTimer(withTimeInterval: Self.weatherUpdateTimerInterval, repeats: true) { _ in
            self.favourites(includeCurrent: true, includeNew: true).forEach { favourite in
                if (favourite.weatherInfo?.current.dt ?? 0).asDate() < Date() - Self.weatherUpdateTimerInterval && favourite.searchResult.lat != nil {
                    self.loadWeatherInfoForLocation(favourite.id)
                }
            }
        }
    }
    
    private func loadWeatherInfoForLocation(_ location: Location) {
        guard let url = WeatherInfo.urlForWeatherInfo(location, apiKey: Self.owmApiKey) else {
            print("••• error building url for location \(location)")
            return
        }
        dispatchPrecondition(condition: .onQueue(.main)) // ok to start our wrapper on the main queue
        url.loadData(queue: .main) { data, response, error in
            dispatchPrecondition(condition: .onQueue(.main)) // our wrapper completes on the main queue
            
            if let data, let weatherInfo = try? WeatherInfo(jsonData: data) { // logs error inside
                self.updateAnyFavourite(location, weatherInfo)
            }
        }
    }
    
    func startAddingNewLocation(_ searchResult: SearchResult) {
        newFavourite = Favourite(searchResult: searchResult, weatherInfo: nil)
        addingNewFavourite = true
        weatherUpdateTimer?.fireDate = .now
    }
    
    func cancelAddingNewLocation() {
        newFavourite = nil
        addingNewFavourite = false
    }
    
    func completeAddingNewLocation() {
        if let newFavourite {
            let alreadyEsixts = state.favourites.contains(where: { favourite in
                favourite.location == newFavourite.location
            })
            if !alreadyEsixts {
                state.favourites.insert(newFavourite, at: 0)
            } else {
                print("••• already exists, improve this later")
            }
            cancelAddingNewLocation()
        }
    }
    
    private func setup() {
        setupAppearance()
        
        if let mockSize = UIImage(named: "mockLocationDetailView.jpg")?.size {
            debugViewOptions.mockSizeMismatch = UIScreen.main.bounds.size.ratio != mockSize.ratio // mock screens provided
        }
        
        startClockUpdateTimer()
        startWeatherUpdateTimer()
        
        setupLocationManager()
    }
    
    private func findSavedFavouriteIndex(_ location: Location) -> Int? {
        state.favourites.firstIndex { $0.id == location }
    }
    
    private func findSavedFavourite(_ location: Location) -> Favourite? {
        guard let index = findSavedFavouriteIndex(location) else { return nil }
        return state.favourites[index]
    }
    
    func findAnyFavourite(_ location: Location) -> Favourite? {
        if location == newFavourite?.searchResult.location {
            return newFavourite
        } else if location == currentFavourite.location {
            return currentFavourite
        } else if let savedFavourite = findSavedFavourite(location) {
            return savedFavourite
        } else {
            print("••••• favorurite not found for get, location: \(location)")
            return nil
        }
    }
    
    private func updateAnyFavourite(_ location: Location, _ weatherInfo: WeatherInfo) {
        if location == newFavourite?.searchResult.location {
            newFavourite?.weatherInfo = weatherInfo
        } else if location == currentFavourite.location {
            currentFavourite.weatherInfo = weatherInfo
        } else if let savedFavouriteIndex = findSavedFavouriteIndex(location) {
            state.favourites[savedFavouriteIndex].weatherInfo = weatherInfo
        } else {
            print("••••• favorurite not found for UPDATE \(location)")
        }
    }
    
    private func setupAppearance() {
        let searchBar = UISearchBar.appearance()
        searchBar.setPositionAdjustment(UIOffset(horizontal: 4, vertical: -1), for: .search)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 5, vertical: -1)
        
        let pageControl = UIPageControl.appearance()
        pageControl.pageIndicatorTintColor = .tertiaryLabel
        pageControl.currentPageIndicatorTintColor = .label
    }
    
    func debugShowMock(_ name: String?) {
        if debugViewOptions.mockFileName != name {
            withAnimation {
                debugViewOptions.mockFileName = name
            }
        }
    }
    
    func debugHideMock(_ name: String?) {
        if debugViewOptions.mockFileName == name {
            withAnimation {
                debugViewOptions.mockFileName = nil
            }
        }
    }
    
    func search(string: String) {
        guard let url = [SearchResult].urlForDirectGeocoding(string, apiKey: Self.owmApiKey) else {
            print("••• error builing direct geocoding url for string \(string)")
            return
        }
        dispatchPrecondition(condition: .onQueue(.main)) // ok to start our wrapper on the main queue
        url.loadData(queue: .main) { data, response, error in
            dispatchPrecondition(condition: .onQueue(.main)) // our wrapper completes on the main queue
            if let data {
                if let searchResults = try? [SearchResult](jsonData: data) { // logs error inside the helper
                    self.searchResults = searchResults
                }
            }
        }
    }
    
    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        updateLocationState()
    }
    
    private func updateLocationState() {
        guard let locationManager else {
            print("••• no location manager")
            return
        }
        switch locationManager.authorizationStatus {
            case .notDetermined:
                print("••• auth state not determined")
                locationServicesAuthorized = false
            case .restricted:
                print("••• auth state restricted")
                locationServicesAuthorized = false
            case .denied:
                print("••• auth state denied")
                locationServicesAuthorized = false
            case .authorizedAlways:
                print("••• auth state availAlways")
                locationServicesAuthorized = true
            case .authorizedWhenInUse:
                print("••• auth state availWhenInUse")
                locationServicesAuthorized = true
            @unknown default:
                fatalError()
        }
        let coordinate = locationManager.location?.coordinate
        currentFavourite.searchResult.lat = coordinate?.latitude
        currentFavourite.searchResult.lon = coordinate?.longitude
        lookupCurrentLocationName()
        weatherUpdateTimer?.fireDate = .now
    }
    
    private func lookupCurrentLocationName() {
        if let lat = currentFavourite.searchResult.lat, let lon = currentFavourite.searchResult.lon {
            let url = [SearchResult].urlForReverseGeocoding(lat: lat, lon: lon, apiKey: Self.owmApiKey)
            dispatchPrecondition(condition: .onQueue(.main)) // ok to start our wrapper on the main queue
            url?.loadData(queue: .main) { data, response, error in
                dispatchPrecondition(condition: .onQueue(.main)) // our wrapper completes on the main queue
                if let data {
                    let searchResult = try? [SearchResult](jsonData: data)
                    self.currentFavourite.searchResult.currentLocationPlace = searchResult?.first?.name
                }
            }
        }
    }
    
    func resetSettings() {
        let defaultSettings = DebugViewOptions()
        let settings = DebugViewOptions(
            showOptions: debugViewOptions.showOptions,
            showFrames: defaultSettings.showFrames,
            showMock: defaultSettings.showMock,
            showInRed: defaultSettings.showInRed,
            layoutAdjustments: defaultSettings.layoutAdjustments,
            showMockSizeMismatchWarning: defaultSettings.showMockSizeMismatchWarning,
            mockSizeMismatch: debugViewOptions.mockSizeMismatch,
            mockFileName: debugViewOptions.mockFileName
        )
        debugViewOptions = settings
        state.favourites = Self.defaultFavorites
        
        DebugViewOptions().removeJson(DebugViewOptions.name)
        [Favourite]().removeJson(Self.dbName)
    }
    
    func requestLocationAuthorization() {
        if locationManager?.authorizationStatus == .denied {
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
                print("error building url for settings")
                return
            }
            UIApplication.shared.open(url)
        } else {
            locationManager?.requestWhenInUseAuthorization()
        }
    }
}

extension TempestasModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocationState()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("••• location manager failed with error: \(error)")
        updateLocationState()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        if oldLocationAuthorizationStatus != status {
            print("••• locationManagerDidChangeAuthorization changed from \(oldLocationAuthorizationStatus) to: \(status)")
            oldLocationAuthorizationStatus = status
            updateLocationState()
            let status = manager.authorizationStatus
            if locationUpdateStarted && (status == .authorizedWhenInUse || status == .authorizedAlways || status == .notDetermined || status == .restricted) {
                locationUpdateStarted = true
                manager.startUpdatingLocation()
            }
        }
    }
}
