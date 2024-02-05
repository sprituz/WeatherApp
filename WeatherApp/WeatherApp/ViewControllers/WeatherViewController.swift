//
//  HomeViewController.swift
//  WeatherApp
//
//  Created by 이다연 on 2023/01/19.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit


class WeatherViewController: UIViewController {
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.text = "시 이름"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 40)
        return label
    }()
    
    private lazy var weatherDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "날씨 설명"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.text = "현재 온도"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var maxTemparatureLabel: UILabel = {
        let label = UILabel()
        label.text = "최고 온도"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var minTemparatureLabel: UILabel = {
        let label = UILabel()
        label.text = "최저 온도"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    private lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.text = "습도"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    var location: String = ""
    
    private var viewModel:WeatherViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        //let a: Observable<WeatherResponse> = apiService.getWeather(lat: 37.5666805, lon: 126.9784147)
        viewModel = WeatherViewModel()
        bind()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(cityLabel)
        view.addSubview(weatherDescriptionLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(maxTemparatureLabel)
        view.addSubview(minTemparatureLabel)
        view.addSubview(humidityLabel)
        
        cityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(200)
        }
        
        weatherDescriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cityLabel.snp.bottom).offset(10)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherDescriptionLabel.snp.bottom).offset(10)
        }
        
        maxTemparatureLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(temperatureLabel.snp.bottom).offset(10)
        }
        
        minTemparatureLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(maxTemparatureLabel.snp.bottom).offset(10)
        }
        
        humidityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(minTemparatureLabel.snp.bottom).offset(10)
        }
    }
    
    private func bind() {
        
        let input = WeatherViewModel.Input(location: Observable.just(location))
        
        let output = viewModel.transform(input: input)
        
        output.data.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] weatherResponse in
            
            self?.cityLabel.text = weatherResponse.name
            
            if let description = weatherResponse.weather.first?.description {
                self?.weatherDescriptionLabel.text  = description
            }
            
            self?.temperatureLabel.text = String(format:"%.2f",weatherResponse.main.temp) + "℃"
            self?.maxTemparatureLabel.text = "최고온도: "+String(format:"%.2f",weatherResponse.main.tempMax) + "℃"
            self?.minTemparatureLabel.text = "최저온도: "+String(format:"%.2f",weatherResponse.main.tempMin) + "℃"
            self?.humidityLabel.text = "습도: "+String(format:"%.2f",weatherResponse.main.humidity) + "%"
            
        }).disposed(by: disposeBag)
    }
    
}

