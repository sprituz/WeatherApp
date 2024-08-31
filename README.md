# SkyCast






> 현재 위치의 날씨 & 원하는 위치의 날씨를 보여주는 앱 </br>

## 목차

- [project](#project)
  - [목차](#목차)
  - [핵심 기능](#핵심-기능)
  - [폴더 구조도](#폴더-구조도)
  - [설치 및 실행 방법](#설치-및-실행-방법)
  - [사용한 기술](#사용한-기술)
  - [라이센스](#라이센스)

## 핵심 기능

OpenWeatherMap API를 이용하여 위치의 시간,날짜별 기온을 조회할 수 있습니다.

| 현재위치 날씨 | 위치 자동완성 검색 | 위치 저장 및 날씨 정보 추가 | 위젯 기능 |
|:--------------:|:------------------:|:-----------------------:|:-------------------------:|
| <img src="https://github.com/user-attachments/assets/cf47cdf2-1157-4252-a078-02ea2d1b0b65" width="300"/> | <img src="https://github.com/user-attachments/assets/c89cf89c-c9de-4986-aded-52c6787dfb77" width="300"/> | <img src="https://github.com/user-attachments/assets/6f9e7309-a0f4-4ca7-9d5a-bbdf7244fd13" width="300"/> | <img src="https://github.com/user-attachments/assets/dc7679d2-0ce1-474b-bc2f-f6c4cc8de7e7" width="300"/> |
| 현재 위치의 날씨를 확인할 수 있습니다. | 위치를 검색할 수 있습니다. | 원하는 위치를 추가할 수 있으며,<br>스와이프하여 간편하게 확인할 수 있습니다. | 위젯으로 현재 위치 날씨를 <br>확인할 수 있습니다. |


지도 기능은 추가될 예정입니다.

## 폴더 구조도

```
├── WeatherApp
│   ├── App
│   │   ├── AppDelegate.swift
│   │   └── SceneDelegate.swift
│   ├── Info.plist
│   ├── Models
│   │   ├── Location.swift
│   │   └── Response
│   │       └── WeatherResponse.swift
│   ├── Protocols
│   │   └── ViewModelProtocol.swift
│   ├── Resources
│   │   ├── Assets.xcassets
│   │   │   ├── AccentColor.colorset
│   │   │   │   └── Contents.json
│   │   │   ├── AppIcon.appiconset
│   │   │   │   └── Contents.json
│   │   │   └── Contents.json
│   │   └── Base.lproj
│   │       └── LaunchScreen.storyboard
│   ├── Services
│   │   ├── APIService.swift
│   │   ├── CityService.swift
│   │   ├── LocationService.swift
│   │   └── UserDefaultsService.swift
│   ├── Utils
│   │   ├── Double+.swift
│   │   └── View+.swift
│   ├── ViewControllers
│   │   ├── PageViewController.swift
│   │   ├── SearchViewController.swift
│   │   └── WeatherViewController.swift
│   ├── ViewModels
│   │   ├── SearchViewModel.swift
│   │   └── WeatherViewModel.swift
│   ├── Views
│   │   ├── DailyCollectionViewCell.swift
│   │   ├── HourlyCollectionViewCell.swift
│   │   └── SavedWeatherTableViewCell.swift
│   ├── WeatherApp++Bundle.swift
│   └── WeatherInfo.plist
└── WeatherWidget
    ├── AppIntent.swift
    ├── Assets.xcassets
    │   ├── AccentColor.colorset
    │   │   └── Contents.json
    │   ├── AppIcon.appiconset
    │   │   └── Contents.json
    │   ├── Contents.json
    │   └── WidgetBackground.colorset
    │       └── Contents.json
    ├── Info.plist
    ├── WeatherWidget.swift
    └── WeatherWidgetBundle.swift
```

## 설치 및 실행 방법

아래 링크에서 API Key를 발급받습니다.

[**OpenWeather**](https://openweathermap.org/)

info.plist와 동일한 경로에 WeatherInfo.plist 라는 이름으로 파일을 생성해주세요.

    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
    <key>WEATHER_API_KEY</key>
    <string>본인의 API key</string>
    </dict>
    </plist>

key는 WEATHER_API_KEY, 값은 본인의 API key 를 넣어주세요.

위 과정을 완료한 후 프로젝트를 클론합니다:

    git clone https://github.com/sprituz/WeatherApp.git
    cd flight-information

.xcworkspace 파일을 열고 프로젝트를 빌드합니다:



## 사용한 기술

- UIKit & Rxswift
    - UIKit를 이용하여 UI 구성
    - RxSwift 을 이용하여 데이터 바인딩 & 비동기 응답 받기
- MVVM
    - 로직과 view를 분리
- WidgetKit
    - 위젯으로 현재위치 기온, 날씨 제공
- Alamofire
    - 간편하게 HTTP 통신
- MapKit
    - 위치(주소) 자동 완성 및 검색 제공


## 라이센스

MIT license
