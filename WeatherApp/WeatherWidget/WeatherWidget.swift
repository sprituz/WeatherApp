//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by 이다연 on 3/22/24.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    typealias Entry = WeatherEntry
    private let locationService = LocationService.shared
    
    func placeholder(in context: Context) -> WeatherEntry {
        WeatherEntry(date: Date(), weather: WeatherResponse())
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherEntry) -> ()) {
        let entry = WeatherEntry(date: Date(), weather: WeatherResponse(name:"Seoul"))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherEntry>) -> ()) {
        let currentDate = Date()
        let nextUpdateDate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        Task {
            // 비동기 함수 호출
            do {
                //현재 위치 정보를 비동기적으로 가져옴
                let currentLocation = await locationService.getCurrentLocation()
                //위치 정보를 기반으로 날씨 정보를 비동기적으로 가져옴
                let weatherResponse = try await APIService.shared.getWeatherAsync(lat: currentLocation?.coordinate.latitude ?? 37, lon: currentLocation?.coordinate.longitude ?? 126)
                
                // 날씨 데이터로 타임라인 엔트리 생성
                let entry = WeatherEntry(date: Date(), weather: weatherResponse)
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate)) // 다음 업데이트는 1시간 후
                completion(timeline)
            } catch {
                // 에러 처리, 기본 데이터로 타임라인 생성
                let entry = WeatherEntry(date: Date(), weather: WeatherResponse())
                let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate)) // 다음 업데이트는 1시간 후
                completion(timeline)
            }
        }
    }
}

struct WeatherEntry: TimelineEntry {
    let date: Date
    let weather: WeatherResponse
}

func backgroundColorForCurrentTime() -> LinearGradient {
    let hour = Calendar.current.component(.hour, from: Date())
    // 아침 6시부터 저녁 6시까지를 아침으로 간주
    if hour >= 6 && hour < 18 {
        // 아침 그라데이션
        return LinearGradient(gradient: Gradient(colors: [.blue, .cyan]), startPoint: .top, endPoint: .bottom)
    } else {
        // 밤 그라데이션
        return LinearGradient(gradient: Gradient(colors: [.black, .blue]), startPoint: .top, endPoint: .bottom)
    }
}

struct WeatherWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack {
            if entry.weather.name ?? "" != "" {
                HStack {
                    Text(entry.weather.name!)
                        .foregroundStyle(.white)
                    Spacer()
                }
                HStack {
                    Text("\(Int(entry.weather.main.temp))°")
                        .foregroundStyle(.white)
                        .font(.system(size: 50, weight: .light))
                    Spacer()
                }
                HStack {
                    Text(entry.weather.weather.first?.description ?? "튼구름")
                        .foregroundStyle(.white)
                    Spacer()
                }
            }
            else {
                Text("날씨 데이터를 불러오는 데 실패했습니다.")
            }
        }
        .padding(.leading) // 간격 자동 설정
        .wigetBackground(backgroundColorForCurrentTime())
    }
}

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WeatherWidgetEntryView(entry: entry)
            //이거 빼야 색이 나옴
            //.containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall,.systemMedium])
        .contentMarginsDisabled()
    }
}


struct WeatherWidget_Previews: PreviewProvider {
    static var previews: some View {
        // 샘플 날씨 데이터 생성
        let sampleWeather = WeatherResponse(name:"Seoul")
        
        // 샘플 WeatherEntry 생성
        let sampleEntry = WeatherEntry(date: Date(), weather: sampleWeather)
        
        // WeatherWidgetEntryView에 샘플 데이터를 전달하여 프리뷰 생성
        WeatherWidgetEntryView(entry: sampleEntry)
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
