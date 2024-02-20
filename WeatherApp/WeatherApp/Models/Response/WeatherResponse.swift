//
//  WeatherResponse.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/22.
//

import Foundation

struct ResponseList: Decodable {
    var cod: String
    var message: Int
    var cnt: Int
    var list: [WeatherResponse]
}

struct WeatherResponse: Decodable {
    var weather: [Weather]
    var main: Main
    var wind: Wind
    var dt: Double
    var name: String?
    
    init(weather: [Weather] = [], main: Main = Main(), wind: Wind = Wind(), dt: Double = 0, name: String = "") {
        self.weather = weather
        self.main = main
        self.wind = wind
        self.dt = dt
        self.name = name
    }
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
    
    init(temp: Double = 0, feelLike: Double = 0, tempMin: Double = 0, tempMax: Double = 0, pressure: Double = 0, humidity: Double = 0) {
        self.temp = temp
        self.feelLike = feelLike
        self.tempMin = tempMin
        self.tempMax = tempMax
        self.pressure = pressure
        self.humidity = humidity
    }
}

struct Wind: Decodable {
    var speed: Double
    var deg: Double
    
    init(speed: Double = 0, deg: Double = 0) {
        self.speed = speed
        self.deg = deg
    }
}

