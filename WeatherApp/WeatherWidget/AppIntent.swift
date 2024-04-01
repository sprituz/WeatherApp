//
//  AppIntent.swift
//  WeatherWidget
//
//  Created by 이다연 on 3/22/24.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Weather"
    static var description = IntentDescription("This is an example widget.")
}
