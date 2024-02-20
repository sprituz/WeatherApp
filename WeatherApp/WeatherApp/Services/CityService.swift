//
//  CityService.swift
//  WeatherApp
//
//  Created by 이다연 on 2/19/24.
//
import Foundation
import RxSwift

final class CityService {
    
    static let shared = CityService()
    
    private init() {}

    //from https://bulk.openweathermap.org/sample/
    lazy var cities: Observable<[Location]> = load("city.list.json").share(replay: 1, scope: .forever)
    
    
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
}
