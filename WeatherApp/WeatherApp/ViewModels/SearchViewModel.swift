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
    
    func load<T: Decodable>(_ filename: String) -> Observable<T> {
        return Observable.create { observer in
            let data: Data
            guard let file = Bundle.main.url(forResource: filename, withExtension: nil)
            else {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't find \(filename) in main bundle."]))
                return Disposables.create()
            }
            
            do {
                data = try Data(contentsOf: file)
            } catch {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't load \(filename) from main bundle:\n\(error)"]))
                return Disposables.create()
            }
            
            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(T.self, from: data)
                observer.onNext(result)
                observer.onCompleted()
            } catch {
                observer.onError(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Couldn't parse \(filename) as \(T.self):\n\(error)"]))
            }
            
            return Disposables.create()
        }
    }
    
    deinit {
        print("SearchViewModel deinitialized")
    }
}
