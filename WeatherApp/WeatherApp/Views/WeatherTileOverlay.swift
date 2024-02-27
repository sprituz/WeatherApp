//
//  WeatherTileOverlay.swift
//  WeatherApp
//
//  Created by 이다연 on 2/27/24.
//

import UIKit
import MapKit

class WeatherTileOverlay: MKTileOverlay {
    let APIKey = "YOUR_OPENWEATHERMAP_API_KEY"
    
    override func url(forTilePath path: MKTileOverlayPath) -> URL {
        let xTileShift = 1 << path.z // 2^z
        let yTile = xTileShift - path.y - 1 // convert y coordinate
        let urlStr = "https://tile.openweathermap.org/map/temp_new/\(path.z)/\(path.x)/\(yTile).png?appid=***REMOVED***"
        return URL(string: urlStr)!
    }
}

