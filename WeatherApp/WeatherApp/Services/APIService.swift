//
//  APIService.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/20.
//

import Foundation
import RxSwift
import Alamofire

class APIService {
    
    static let shared = APIService()
    let appid = Bundle.main.WEATHER_API_KEY
    
    private init() {}
    
    // URL을 구성하기 위한 enum
    enum WeatherServiceEndpoint {
        case byCityName(String)
        case byCoordinates(Double, Double)
        
        private var baseURL: String {
            return "https://api.openweathermap.org/data/2.5/weather"
        }
        
        func url(appid: String) -> URL? {
            var components = URLComponents(string: baseURL)
            var queryItems = [URLQueryItem(name: "APPID", value: appid),
                              URLQueryItem(name: "lang", value: "kr"),
                              URLQueryItem(name: "units", value: "metric")]
            
            switch self {
            case .byCityName(let city):
                queryItems.append(URLQueryItem(name: "q", value: city))
            case .byCoordinates(let lat, let lon):
                queryItems.append(URLQueryItem(name: "lat", value: "\(lat)"))
                queryItems.append(URLQueryItem(name: "lon", value: "\(lon)"))
            }
            
            components?.queryItems = queryItems
            return components?.url
        }
    }
    
    private func performRequest(url: URL) -> Observable<WeatherResponse> {
        return Observable.create { observer in
            let request = AF.request(url).response { response in
                switch response.result {
                case .success(let data):
                    do {
                        let model = try JSONDecoder().decode(WeatherResponse.self, from: data ?? Data())
                        observer.onNext(model)
                    } catch {
                        observer.onError(error)
                    }
                case .failure(let error):
                    observer.onError(error)
                }
                observer.onCompleted()
            }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    func getWeather(lat: Double, lon: Double) -> Observable<WeatherResponse> {
        guard let url = WeatherServiceEndpoint.byCoordinates(lat, lon).url(appid: self.appid) else {
            return Observable.error(NetworkError.outOfBounds)
        }
        return performRequest(url: url)
    }
    
    func getWeather(city: String) -> Observable<WeatherResponse> {
        guard let url = WeatherServiceEndpoint.byCityName(city).url(appid: self.appid) else {
            return Observable.error(NetworkError.cityNotFound)
        }
        return performRequest(url: url)
    }
    
    enum NetworkError: Error {
        case outOfBounds
        case cityNotFound
    }
}
