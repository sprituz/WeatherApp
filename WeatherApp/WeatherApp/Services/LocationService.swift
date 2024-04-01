//
//  LocationService.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/30.
//

import RxSwift
import RxCocoa
import CoreLocation

final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    let locationManager = CLLocationManager()
    public let location: BehaviorRelay<CLLocation?> = BehaviorRelay(value: nil)
    private var disposeBag = DisposeBag()
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
        print(locations.last)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

// LocationService 클래스 내부
extension LocationService {
    func getCurrentLocation() async -> CLLocation? {
        if let currentLocation = location.value {
            // 현재 위치가 이미 존재하는 경우 해당 위치를 반환합니다.
            return currentLocation
        } else {
            locationManager.requestLocation()
            // 위치 업데이트가 발생할 때까지 대기합니다.
            return await withUnsafeContinuation { continuation in
                // 새로운 위치가 업데이트될 때마다 호출됩니다.
                location
                    .filter { $0 != nil }
                    .take(1)
                    .subscribe(onNext: { location in
                        if let location = location {
                            continuation.resume(returning: location)
                        }
                    })
                    .disposed(by: disposeBag)
                // 메모리 누수를 방지하기 위해 DisposeBag에 disposable을 추가합니다.
            }
        }
    }
}

