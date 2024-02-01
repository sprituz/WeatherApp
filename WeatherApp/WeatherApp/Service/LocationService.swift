//
//  LocationService.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/30.
//

import RxSwift
import RxCocoa
import CoreLocation

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    let locationManager = CLLocationManager()
    public let location: BehaviorRelay<CLLocation?> = BehaviorRelay(value: nil)
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 100.0
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // 사용자가 권한을 승인했을 때 위치 업데이트를 시작합니다.
            locationManager.startUpdatingLocation()
        default:
            // 권한이 없는 경우 처리
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 가장 최근의 위치 정보를 받아 BehaviorRelay에 저장합니다.
        location.accept(locations.last)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
