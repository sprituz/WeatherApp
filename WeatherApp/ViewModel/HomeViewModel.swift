//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/19.
//

import Foundation
import RxSwift
import CoreLocation

final class HomeViewModel {
    
    private let apiService = APIService.shared
    private let locationManager = LocationService.shared
    
    struct input {
        
    }
    
    struct output {
        let data: Observable<WeatherResponse>
    }
    
    func transform() -> output {
        let data = locationManager.location
            .flatMapLatest { [weak self] location -> Observable<WeatherResponse> in
                guard let self = self else { return Observable.empty() }
                guard let location = location else { return Observable.empty() }
                
                return self.apiService.getWeather(lat: location.coordinate.latitude, lon: location.coordinate.longitude)
            }

        return output(data: data)
    }

    
}
