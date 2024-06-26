//
//  HomeViewModel.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/19.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

final class WeatherViewModel {
    
    private let apiService = APIService.shared
    private let locationService = LocationService.shared
    private let userDefaultsService = UserDefaultsService.shared
    
    struct Input {
        let location: Observable<Coord>
        let addButtonTapped: Observable<Void>
    }
    
    struct Output {
        let data: Observable<WeatherResponse>
        let icon: Observable<UIImage>
        let dailyData: Observable<[WeatherResponse]>
        let dailyIcons: Observable<[UIImage]>
        let hourlyData: Observable<ResponseList>
        let hourlyIcons: Observable<[UIImage]>
        let shouldShowAddButton: Observable<Bool>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let data = input.location
            .flatMapLatest { [weak self] location -> Observable<WeatherResponse> in
                guard let self = self else { return Observable.empty() }
                
                if location == Coord(lon: nil, lat: nil) {
                    return self.locationService.location
                        .flatMapLatest { currentLocation -> Observable<WeatherResponse> in
                            guard let currentLocation = currentLocation else { return Observable.empty() }
                            return self.apiService.getWeather(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude)
                        }
                } else {
                    return self.apiService.getWeather(lat: location.lat!, lon: location.lon!)
                }
            }
        
        input.addButtonTapped
            .withLatestFrom(input.location) // 최신 위치 데이터를 가져옵니다.
            .subscribe(onNext: { [weak self] location in
                self?.userDefaultsService.storeLocationData(location)
            })
            .disposed(by: disposeBag)
        
        let icon = data
            .flatMapLatest { [weak self] response -> Observable<UIImage> in
                guard let self = self else { return Observable.empty() }
                
                let weatherIcon = response.weather.first?.icon ?? ""
                return self.apiService.getWeatherIcon(icon: weatherIcon)
            }
        
        
        
        let dailyData = input.location
            .flatMapLatest { [weak self] location -> Observable<[WeatherResponse]> in
                guard let self = self else { return Observable.empty() }
                let observable: Observable<ResponseList>
                if location == Coord(lon: nil, lat: nil) {
                    observable = self.locationService.location
                        .flatMapLatest { currentLocation -> Observable<ResponseList> in
                            guard let currentLocation = currentLocation else { return Observable.empty() }
                            return self.apiService.getDailyWeather(lat: currentLocation.coordinate.latitude, lon: currentLocation.coordinate.longitude)
                        }
                } else {
                    observable = self.apiService.getDailyWeather(lat: location.lat!, lon: location.lon!)
                }
                
                return observable
                    .map { responseList in
                        let grouped = Dictionary(grouping: responseList.list, by: { $0.dt.fromTimestamp(format: "MM/dd") })
                        return grouped.map { date, list in
                            let minTemp = list.min(by: { $0.main.tempMin < $1.main.tempMin })?.main.tempMin
                            let maxTemp = list.max(by: { $0.main.tempMax < $1.main.tempMax })?.main.tempMax
                            let avgHumidity = list.map { $0.main.humidity }.reduce(0, +) / Double(list.count)
                            return WeatherResponse(weather: list.first?.weather ?? [], main: Main(temp: list.first?.main.temp ?? 0, feelLike: list.first?.main.feelLike ?? 0, tempMin: minTemp ?? 0, tempMax: maxTemp ?? 0, pressure: list.first?.main.pressure ?? 0, humidity: avgHumidity), wind: list.first?.wind ?? Wind(), dt: list.first?.dt ?? 0, name: list.first?.name ?? "")
                        }
                    }
                    .map { $0.sorted(by: { $0.dt < $1.dt }) }  // 날짜순으로 정렬
                    .map { Array($0.prefix(5)) }  // 상위 5개 요소만 선택
            }
        
        
        let dailyIcons = dailyData
            .flatMap { dataList -> Observable<[UIImage]> in
                let iconObservables = dataList.map { weatherResponse -> Observable<UIImage> in
                    let icon = weatherResponse.weather.first?.icon ?? ""
                    return self.apiService.getWeatherIcon(icon: icon)
                }
                return Observable.combineLatest(iconObservables)
            }
        
        
        
        let hourlyData = input.location
            .flatMapLatest { [weak self] location -> Observable<ResponseList> in
                guard let self = self else { return Observable.empty() }
                
                if location == Coord(lon: nil, lat: nil) {
                    return self.locationService.location
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
        
        let myLocation = userDefaultsService.locationData()
        
        let shouldShowAddButton = input.location
            .flatMapLatest { location -> Observable<Bool> in
                
                guard let _ = location.lon, let _ = location.lat else {
                    return .just(false)
                }
                
                return myLocation
                    .map { locations in
                        // UserDefaults에 같은 위치 정보가 없으면 true (추가 버튼 보이게), 있으면 false (추가 버튼 숨기게)
                        !locations.contains(location)
                    }
            }
            .startWith(false)
        
        return Output(data: data, icon: icon, dailyData: dailyData, dailyIcons: dailyIcons, hourlyData: hourlyData, hourlyIcons: hourlyIcons, shouldShowAddButton: shouldShowAddButton)
    }
}
