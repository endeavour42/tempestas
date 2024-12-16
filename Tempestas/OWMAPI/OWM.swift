//
//  OWM.swift
//  Tempestas
//
//  Created by endeavour42 on 15/12/2024.
//

import Foundation

enum OWM {} // empty

extension OWM {
    
    struct Location: Identifiable, Hashable {
        var id: Self { self }
        let lat: Double?
        let lon: Double?
        let isCurrentLocation: Bool
    }

    struct SearchResult: Identifiable, Codable {
        var id: Location { location }
        var location: Location {
            Location(lat: lat, lon: lon, isCurrentLocation: isCurrentLocation ?? false)
        }
        var local_names: [String: String]?
        var name: String?                       // non optional in the API
        var currentLocationPlace: String?       // not part of API
        var isCurrentLocation: Bool?            // not part of API
        var lat: Double?                        // non optional in the API
        var lon: Double?                        // non optional in the API
        var country: String?
        var state: String?
        
        var shortName: String {
            name ?? "My Location"
        }
        var fullName: String {
            if let name {
                name + ", " + (state ?? "") + " " + (country ?? "")
            } else {
                shortName
            }
        }
    }
    
    struct Favourite: Identifiable, Codable {
        var id: Location { location }           // TODO: think of a better way
        var location: Location { searchResult.location }
        var searchResult: SearchResult
        var weatherInfo: WeatherInfo?
    }
    
    struct WeatherInfo: Codable {
        var lat: Double
        var lon: Double
        var timezone: String
        var timezone_offset: Int        // TODO: here and in other places: consider renaming to camelCase
        var current: Current
        // var minutely: [Minutely]?
        // var hourly: [Hourly]?
        var daily: [Daily]?
        var alerts: [Alert]?
    }
    
//    struct Minutely: Codable {
//        var dt: Int?
//        var precipitation: Int?
//    }
    
    struct Weather: Codable {
        var id: Int
        var main: String
        var description: String         // TODO: here and other places: consider renaming, as there's a clash with built-in `description`
        var icon: String
    }
    
    struct Rain1H: Codable {
        let _1h: Double
        enum CodingKeys: String, CodingKey {
            case _1h = "1h"
        }
    }
    
//    struct Hourly: Codable {
//        var dt: Int
//        
//        var temp: Double
//        var feels_like: Double
//        
//        var pressure: Int
//        var humidity: Int
//        var dew_point: Double
//        
//        var wind_speed: Double
//        var wind_gust: Double?
//        var wind_deg: Int
//        
//        var clouds: Int
//        var uvi: Double
//        
//        var visibility: Int
//        
//        var pop: Double
//        
//        var rain: Rain1H?
//        var snow: Double?
//        var weather: [Weather]
//    }
    
    struct Current: Codable {
        var dt: Int
        
        var sunrise: Int?
        var sunset: Int?
        
        var temp: Double
        var feels_like: Double?
        
        var pressure: Int?
        var humidity: Int?
        var dew_point: Double?
        
        var wind_speed: Double?
        var wind_gust: Double?
        var wind_deg: Int?
        
        var clouds: Int?
        var uvi: Double?
        
        var visibility: Int?
        
//        var rain: Double? // dictionary?
//        var snow: Double?
        var weather: [Weather]
    }
    
    struct Daily: Codable {
        var dt: Int
        
        var sunrise: Int?
        var sunset: Int?
        var moonrise: Int?
        var moonset: Int?
        var moon_phase: Double?
        
        var temp: DailyTemp
        var feels_like: DailyFeelsLike?
        
        var pressure: Int?
        var humidity: Int?
        var dew_point: Double?
        
        var wind_speed: Double?
        var wind_gust: Double?
        var wind_deg: Int?
        
        var summary: String?
        
        var uvi: Double?
        var clouds: Int?
        
        var pop: Double?
        
//        var rain: Double? // dictionary?
//        var snow: Double?
        var weather: [Weather]
    }
    
    struct DailyTemp: Codable {
        var morn: Double?
        var day: Double
        var eve: Double?
        var night: Double?
        var min: Double
        var max: Double
    }
    
    struct DailyFeelsLike: Codable {
        var morn: Double?
        var day: Double?
        var eve: Double?
        var night: Double?
    }
    
    struct Alert: Codable {
        var sender_name: String?
        var event: String?
        var start: Int?
        var end: Int?
        var description: String?
        var tags: [String]?
    }
}

extension OWM.Daily: Identifiable {
    var id: Int { dt }
    var iconCode: String? {
        weather.first?.icon
    }
}

extension OWM {
    private static let host = "open" + "weather" + "map" + ".org"
    static let iconHost = host
    static let apiHost = "api." + iconHost
}

extension OWM.WeatherInfo {
    static func urlForWeatherInfo(_ location: Location?, apiKey: String) -> URL? {
        guard let location, let lat = location.lat, let lon = location.lon else { return nil }
        let string = "https://\(OWM.apiHost)/data/3.0/onecall?lat=\(lat)&lon=\(lon)&exclude=minutely,hourly,alerts&appid=\(apiKey)"
        return URL(string: string)
    }
}

extension [OWM.SearchResult] {
    static func urlForDirectGeocoding(_ name: String?, apiKey: String) -> URL? {
        guard let name else { return nil }
        let string = "https://\(OWM.apiHost)/geo/1.0/direct?q=\(name)&limit=5&appid=\(apiKey)"
        return URL(string: string)
    }
    static func urlForReverseGeocoding(lat: Double?, lon: Double?, apiKey: String) -> URL? {
        guard let lat, let lon else { return nil }
        let string = "https://\(OWM.apiHost)/geo/1.0/reverse?lat=\(lat)&lon=\(lon)&limit=2&appid=\(apiKey)"
        return URL(string: string)
    }
}

extension OWM {
    static func urlForIcon(iconCode: String?) -> URL? {
        guard let iconCode else { return nil }
        let string = "https://\(OWM.iconHost)/img/wn/\(iconCode)@4x.png"
        return URL(string: string)
    }
}
