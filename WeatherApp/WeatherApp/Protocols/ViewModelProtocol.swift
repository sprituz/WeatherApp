//
//  ViewModelProtocol.swift
//  WeatherApp
//
//  Created by 이다연 on 8/28/24.
//

import Foundation

protocol ViewModelProtocol {
    
    associatedtype Input
    
    associatedtype Output
    
    func transform(input: Input) -> Output
}
