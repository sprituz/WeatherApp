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
    
    struct Input {
        let text: Observable<String>
    }
    
    struct Output {
        let data: Observable<[Location]>
    }
    
    
    func transform(input: Input) -> Output {
        let data = input.text.flatMapLatest { text in
            self.cities.map { location in
                location.filter { $0.name.lowercased().contains(text.lowercased()) }
            }
        }
        return Output(data: data)
    }
}
