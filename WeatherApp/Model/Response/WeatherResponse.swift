//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/22.
//

import Foundation

struct WeatherResponse: Decodable {
    var weather: [Weather]
    var main: Main
    var wind: Wind
    var name: String
}

struct Weather: Decodable {
    var id: Int
    var main: String
    var description: String
    var icon: String
}

struct Main: Decodable {
    var temp: Double
    var feelLike: Double
    var tempMin: Double
    var tempMax: Double
    var pressure: Double
    var humidity: Double
    
    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case feelLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct Wind: Decodable {
    var speed: Double
    var deg: Double
}
