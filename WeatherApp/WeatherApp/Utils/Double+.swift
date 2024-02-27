//
//  Double+.swift
//  WeatherApp
//
//  Created by 이다연 on 2/19/24.
//

import Foundation

extension Double {
    func fromTimestamp(format: String) -> String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}
