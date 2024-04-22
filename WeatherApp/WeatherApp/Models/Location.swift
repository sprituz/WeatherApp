//
//  City.swift
//  WeatherApp
//
//  Created by 이다연 on 2/13/24.
//

import Foundation

struct Location: Codable {
    let id: Int
    let name: String
    let country: String
    let coord: Coord
}

struct Coord: Codable,Equatable {
    let lon: Double?
    let lat: Double?
}
