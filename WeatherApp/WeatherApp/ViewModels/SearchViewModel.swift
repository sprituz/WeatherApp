//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by 이다연 on 2/5/24.
//

import UIKit
import RxSwift

final class SearchViewModel {
    
    //from https://bulk.openweathermap.org/sample/
    lazy var cities: Observable<[Location]> =  CityService.shared.cities
    
    private let apiService = APIService.shared
    private let userDefaultsService = UserDefaultsService.shared
    
    struct Input {
        let text: Observable<String>
        let deleteTrigger: Observable<Coord>
    }
    
    struct Output {
        let data: Observable<[Location]>
        let myLocation: Observable<[Coord]>
        let savedWeatherData: Observable<[WeatherResponse]>
    }
    
    var disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        let data = input.text.flatMapLatest { text in
            self.cities.map { location in
                location.filter { $0.name.lowercased().contains(text.lowercased()) }
            }
        }
        
        input.deleteTrigger
                   .subscribe(onNext: { coord in
                       self.userDefaultsService.deleteLocationData(coord)
                       // UserDefaults에서 데이터를 다시 불러와 locations를 업데이트
                   })
                   .disposed(by: disposeBag)
        
        let myLocation = userDefaultsService.locationData()
        
        let savedWeatherData = myLocation.flatMapLatest { coordArray in
            // coordArray에 있는 각 Coord에 대해 날씨 데이터를 요청하는 Observable을 생성합니다.
            let weatherObservables = coordArray.map { coord in
                self.apiService.getWeather(lat: coord.lat ?? 0, lon: coord.lon ?? 0)
            }
            // Observable.from을 사용하여 Observable<Observable<WeatherData>>를 Observable<WeatherData>로 변환합니다.
            return Observable.from(weatherObservables)
                .merge() // 모든 날씨 데이터 요청을 병합합니다.
                .toArray() // 결과를 배열로 변환합니다.
                .asObservable() // 최종적으로 Observable<[WeatherData]>를 반환합니다.
        }
        
        return Output(data: data, myLocation: myLocation, savedWeatherData: savedWeatherData)
    }
}
