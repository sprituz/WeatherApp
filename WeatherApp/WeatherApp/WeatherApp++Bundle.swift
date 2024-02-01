//
//  WeatherApp++Bundle.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/25.
//

import Foundation

extension Bundle {
    var WEATHER_API_KEY: String {
        guard let file = self.path(forResource: "WeatherInfo", ofType: "plist") else { return "" }
        
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        
        guard let key = resource["WEATHER_API_KEY"] as? String else {
            fatalError("WEATHER_API_KEY error")
        }
        return key
    }
}
