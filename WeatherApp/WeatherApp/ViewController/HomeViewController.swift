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


class HomeViewController: UIViewController {
    
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
    
    
    private var viewModel:HomeViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureUI()
        //let a: Observable<WeatherResponse> = apiService.getWeather(lat: 37.5666805, lon: 126.9784147)
        viewModel = HomeViewModel()
        bind()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(cityLabel)
        view.addSubview(weatherDescriptionLabel)
        view.addSubview(temperatureLabel)
        
        weatherDescriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cityLabel.snp.bottom).offset(20)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherDescriptionLabel.snp.bottom).offset(20)
        }
        
        cityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(200)
        }
    }
    
    private func bind() {
        
        let output = viewModel.transform()
        
        output.data.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] weatherResponse in
            
            self?.cityLabel.text = weatherResponse.name
            
            if let description = weatherResponse.weather.first?.description {
                self?.weatherDescriptionLabel.text  = description
            }
            
            self?.temperatureLabel.text = String(format:"%.2f",weatherResponse.main.temp) + "℃"
            
        }).disposed(by: disposeBag)
    }
    
}

