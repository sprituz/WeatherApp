//
//  APIService.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/20.
//

import Foundation
import RxSwift
import Alamofire
import UIKit

final class APIService {
    
    static let shared = APIService()
    let appid = Bundle.main.WEATHER_API_KEY
    
    private init() {}
    
    // URL을 구성하기 위한 enum
    enum WeatherServiceEndpoint {
        case byCoordinates(Double, Double)
        case weatherIcon(String)
        case dailyForecast(Double, Double)
        case hourlyForecast(Double, Double)
        
        private var baseURL: String {
            return "https://api.openweathermap.org/"
        }
        
        func url(appid: String) -> URL? {
            var components = URLComponents(string: baseURL + "data/2.5/weather")
            var queryItems = [
                URLQueryItem(name: "APPID", value: appid),
                URLQueryItem(name: "lang", value: "kr"),
                URLQueryItem(name: "units", value: "metric")
            ]
            
            switch self {
            case .byCoordinates(let lat, let lon):
                queryItems.append(URLQueryItem(name: "lat", value: "\(lat)"))
                queryItems.append(URLQueryItem(name: "lon", value: "\(lon)"))
            case .weatherIcon(let icon):
                let urlString = baseURL + "img/w/" + icon + ".png"
                return URL(string: urlString)
            case .dailyForecast(let lat, let lon):
                components = URLComponents(string: baseURL + "data/2.5/forecast/daily")
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(lon)"),
                    URLQueryItem(name: "exclude", value: "minutely,daily,alerts"),
                    URLQueryItem(name: "units", value: "metric"),
                    URLQueryItem(name: "APPID", value: appid)
                ])
                
            case .hourlyForecast(let lat, let lon):
                components = URLComponents(string: baseURL + "data/2.5/forecast")
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "lat", value: "\(lat)"),
                    URLQueryItem(name: "lon", value: "\(lon)"),
                    URLQueryItem(name: "exclude", value: "minutely,daily,alerts"),
                    URLQueryItem(name: "cnt", value: "8"),
                    URLQueryItem(name: "units", value: "metric"),
                    URLQueryItem(name: "APPID", value: appid)
                ])
            }
            components?.queryItems = queryItems
            return components?.url
        }
    }
    
    
    private func performRequest<T: Decodable>(url: URL) -> Observable<T> {
        return Observable.create { observer in
            let request = AF.request(url).response { response in
                switch response.result {
                case .success(let data):
                    do {
                        let model = try JSONDecoder().decode(T.self, from: data ?? Data())
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
    
    private func performRequestIcon(url: URL) -> Observable<UIImage> {
        return Observable.create { observer in
            let request = AF.request(url).response { response in
                switch response.result {
                case .success(let data):
                    let icon = UIImage(data: data ?? Data())
                    observer.onNext(icon ?? UIImage())
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
            return Observable.error(NetworkError.invalidURL)
        }
        return performRequest(url: url)
    }
    
    func getWeatherIcon(icon: String) -> Observable<UIImage> {
        guard let url = WeatherServiceEndpoint.weatherIcon(icon).url(appid: self.appid) else {
            return Observable.error(NetworkError.invalidURL)
        }
        return performRequestIcon(url: url)
    }
    
    func getDailyWeather(lat: Double, lon: Double) -> Observable<ResponseList> {
        guard let url = WeatherServiceEndpoint.dailyForecast(lat, lon).url(appid: self.appid) else {
            return Observable.error(NetworkError.invalidURL)
        }
        return performRequest(url: url)
    }
    
    func getHourlyWeather(lat: Double, lon: Double) -> Observable<ResponseList> {
        guard let url = WeatherServiceEndpoint.hourlyForecast(lat, lon).url(appid: self.appid) else {
            return Observable.error(NetworkError.invalidURL)
        }
        return performRequest(url: url)
    }
    
    
    enum NetworkError: Error {
        case invalidURL
    }
}
