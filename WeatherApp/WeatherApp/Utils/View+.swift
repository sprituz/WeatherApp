//
//  View+.swift
//  WeatherApp
//
//  Created by 이다연 on 3/28/24.
//

import Foundation
import SwiftUI

extension View {
    func wigetBackground(_ gradient: LinearGradient) -> some View {
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(gradient, for: .widget)
        } else {
            return background(gradient)
        }
    }
}
