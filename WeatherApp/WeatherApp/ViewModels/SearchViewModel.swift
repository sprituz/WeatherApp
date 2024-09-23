//
//  SearchViewModel.swift
//  WeatherApp
//
//  Created by 이다연 on 2/5/24.
//

import UIKit
import RxSwift
import MapKit

final class SearchViewModel: NSObject, ViewModelProtocol, MKLocalSearchCompleterDelegate {
    
    override init() {
        super.init()
        searchCompleter.delegate = self
    }
    
    private let apiService = APIService.shared
    private let userDefaultsService = UserDefaultsService.shared
    
    private let searchResultsSubject = PublishSubject<[MKLocalSearchCompletion]>()
    private let searchLocationResultSubject = PublishSubject<CLLocationCoordinate2D>()
    
    private let searchCompleter = MKLocalSearchCompleter()
    private let disposeBag = DisposeBag()
    
    struct Input {
        let searchQuery: Observable<String>
        let selectedLocation: Observable<MKLocalSearchCompletion>
        let deleteTrigger: Observable<(Coord, WeatherResponse)>
    }
    
    struct Output {
        let searchResults: Observable<[MKLocalSearchCompletion]>
        let coordinate: Observable<CLLocationCoordinate2D>
        let savedWeatherData: Observable<[(Coord, WeatherResponse)]>
    }
    
    func transform(input: Input) -> Output {
        
        
        input.searchQuery
            .subscribe(onNext: { query in
                self.searchCompleter.queryFragment = query
            })
            .disposed(by: disposeBag)
        
        input.selectedLocation
            .subscribe(onNext: { location in
                self.searchLocation(location)
            })
            .disposed(by: disposeBag)
        
        input.deleteTrigger
            .subscribe(onNext: { (coord,weatherResponse) in
                self.userDefaultsService.deleteLocationData(coord)
                // UserDefaults에서 데이터를 다시 불러와 locations를 업데이트
            })
            .disposed(by: disposeBag)
        
        let myLocation = userDefaultsService.locationData()
        
        let savedWeatherData = myLocation.flatMapLatest { coordArray in
            // coordArray에 있는 각 Coord에 대해 날씨 데이터와 위치 정보를 묶어서 반환하는 Observable을 생성합니다.
            let weatherObservables = coordArray.map { coord in
                self.apiService.getWeather(lat: coord.lat ?? 0, lon: coord.lon ?? 0)
                    .map { weatherResponse -> (Coord, WeatherResponse) in
                        // 날씨 데이터와 위치 정보를 튜플로 묶어서 반환합니다.
                        return (coord, weatherResponse)
                    }
            }
            // Observable.from을 사용하여 Observable<Observable<(Coord, WeatherData)>>를 Observable<(Coord, WeatherData)>로 변환합니다.
            return Observable.from(weatherObservables)
                .merge() // 모든 날씨 데이터 요청을 병합합니다.
                .toArray() // 결과를 배열로 변환합니다.
                .asObservable() // 최종적으로 Observable<[(Coord, WeatherData)]>를 반환합니다.
        }
        
        
        
        return Output(searchResults: searchResultsSubject, coordinate: searchLocationResultSubject, savedWeatherData: savedWeatherData)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResultsSubject.onNext(completer.results)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
    
    func searchLocation(_ completion: MKLocalSearchCompletion) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        
        search.start { response, error in
            guard let response = response, error == nil else {
                print("Error occurred: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let mapItem = response.mapItems.first {
                let coordinate = mapItem.placemark.coordinate
                self.searchLocationResultSubject.onNext(coordinate)
                print("Latitude: \(coordinate.latitude), Longitude: \(coordinate.longitude)")
            }
        }
    }
}
