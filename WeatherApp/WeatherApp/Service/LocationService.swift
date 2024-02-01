//
//  LocationService.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/30.
//

import RxSwift
import RxCocoa
import CoreLocation

class LocationService: NSObject {
    
    static let shared = LocationService()
    let locationManager = CLLocationManager()
    public let location: BehaviorRelay<CLLocation?> = BehaviorRelay(value: nil)
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 100.0
        locationManager.requestLocation()
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location.accept(locations.last)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
