//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/19.
//

import UIKit
import RxSwift
import CoreLocation

final class WeatherViewModel {
    
    private let apiService = APIService.shared
    private let locationManager = LocationService.shared
    
    struct Input {
        let location: Observable<Coord>
    }
    
    struct Output {
        let data: Observable<WeatherResponse>
        let icon: Observable<UIImage>
        let dailyData: Observable<ResponseList>
        let hourlyData: Observable<ResponseList>
        let hourlyIcons: Observable<[UIImage]>
    }
    
    func transform(input: Input) -> Output {
        let data = input.location
            .flatMapLatest { [weak self] location -> Observable<WeatherResponse> in
                guard let self = self else { return Observable.empty() }
                
                if location == Coord(lon: nil, lat: nil) {
                    return self.locationManager.location
                        .flatMapLatest { currentLocation -> Observable<WeatherResponse> in
                            guard let currentLocation = currentLocation else { return Observable.empty() }
                            return self.apiService.getWeather(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude)
                        }
                } else {
                    return self.apiService.getWeather(lat: location.lat!, lon: location.lon!)
                }
            }
        
        let icon = data
            .flatMapLatest { [weak self] response -> Observable<UIImage> in
                guard let self = self else { return Observable.empty() }
                
                let weatherIcon = response.weather.first?.icon ?? ""
                return self.apiService.getWeatherIcon(icon: weatherIcon)
            }
        
        
        
        let dailyData = input.location
            .flatMapLatest { [weak self] location -> Observable<ResponseList> in
                guard let self = self else { return Observable.empty() }
                
                if location == Coord(lon: nil, lat: nil) {
                    return self.locationManager.location
                        .flatMapLatest { currentLocation -> Observable<ResponseList> in
                            guard let currentLocation = currentLocation else { return Observable.empty() }
                            return self.apiService.getDailyWeather(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude)
                        }
                } else {
                    return self.apiService.getDailyWeather(lat: location.lat!, lon: location.lon!)
                }
            }
        
        let hourlyData = input.location
            .flatMapLatest { [weak self] location -> Observable<ResponseList> in
                guard let self = self else { return Observable.empty() }
                
                if location == Coord(lon: nil, lat: nil) {
                    return self.locationManager.location
                        .flatMapLatest { currentLocation -> Observable<ResponseList> in
                            guard let currentLocation = currentLocation else { return Observable.empty() }
                            return self.apiService.getHourlyWeather(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude)
                        }
                } else {
                    return self.apiService.getHourlyWeather(lat: location.lat!, lon: location.lon!)
                }
            }
        
        let hourlyIcons = hourlyData
                    .flatMap { responseList -> Observable<[UIImage]> in
                        let iconObservables = responseList.list.map { weatherResponse -> Observable<UIImage> in
                            let icon = weatherResponse.weather.first?.icon ?? ""
                            return self.apiService.getWeatherIcon(icon: icon)
                        }
                        return Observable.combineLatest(iconObservables)
                    }
        
        return Output(data: data, icon: icon, dailyData: dailyData, hourlyData: hourlyData, hourlyIcons: hourlyIcons)
    }
}
