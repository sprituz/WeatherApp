//
//  UserDefaultsservice.swift
//  WeatherApp
//
//  Created by 이다연 on 3/7/24.
//

import RxSwift
import Foundation

class UserDefaultsService {
    
    static let shared = UserDefaultsService()
    
    private init() {}
    
    private let standard = UserDefaults.standard
    
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    
    let locationDataChanged = PublishSubject<Void>()
    
    func locationData() -> Observable<[Coord]> {
        return locationDataChanged
            .startWith(()) // 초기 구독 시점에도 데이터를 불러오기 위해 사용
            .flatMapLatest { _ -> Observable<[Coord]> in // locationDataChanged 이벤트가 발생할 때마다 실행
                Observable.create { observer in
                    if let savedLocationData = UserDefaults.standard.object(forKey: "myLocation") as? Data {
                        do {
                            let loadedLocationData = try self.decoder.decode([Coord].self, from: savedLocationData)
                            observer.onNext(loadedLocationData) // 성공한 경우 데이터 방출
                        } catch {
                            observer.onError(error) // 디코딩 실패한 경우 에러 방출
                        }
                    } else {
                        observer.onNext([]) // 저장된 데이터가 없는 경우 빈 배열 방출
                    }
                    return Disposables.create() // 필요한 경우 리소스 해제를 위한 구문
                }
            }
    }

    
    // 삭제 메소드 구현
    func deleteLocationData(_ coord: Coord) {
        if let savedLocationData = standard.object(forKey: "myLocation") as? Data,
           let loadedLocationData = try? decoder.decode([Coord].self, from: savedLocationData) {
            let updatedLocationData = loadedLocationData.filter { $0 != coord }
            if let encoded = try? encoder.encode(updatedLocationData) {
                standard.set(encoded, forKey: "myLocation")
            }
        }
        locationDataChanged.onNext(())
    }
    
    // 중복되지 않는 요소만 추가하는 메소드 구현
    func storeLocationData(_ coord: Coord) {
        if let savedLocationData = standard.object(forKey: "myLocation") as? Data,
           var loadedLocationData = try? decoder.decode([Coord].self, from: savedLocationData) {
            if !loadedLocationData.contains(coord) {
                loadedLocationData.append(coord)
                if let encoded = try? encoder.encode(loadedLocationData) {
                    standard.set(encoded, forKey: "myLocation")
                }
            }
        } else {
            // 저장된 데이터가 없는 경우 새 배열을 만들어 저장합니다.
            let newLocationData = [coord]
            if let encoded = try? encoder.encode(newLocationData) {
                standard.set(encoded, forKey: "myLocation")
            }
        }
        locationDataChanged.onNext(())
    }
}
