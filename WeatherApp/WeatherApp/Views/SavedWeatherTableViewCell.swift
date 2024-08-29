//
//  SavedWeatherTableViewCell.swift
//  WeatherApp
//
//  Created by 이다연 on 4/8/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class SavedWeatherTableViewCell: UITableViewCell {
    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    
    private let weatherInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    private let weatherLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(locationLabel)
        contentView.addSubview(weatherInfoLabel)
        contentView.addSubview(weatherLabel)
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.lessThanOrEqualTo(weatherInfoLabel.snp.leading).offset(-30) // 이 조건을 추가하여 충돌 방지
        }
        
        weatherInfoLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(16)
        }
        
        weatherLabel.snp.makeConstraints { make in
            make.top.equalTo(weatherInfoLabel.snp.bottom).offset(8)
            make.trailing.equalToSuperview().inset(16)
            make.bottom.lessThanOrEqualToSuperview().inset(8) // 바닥에 닿지 않도록 설정
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with weatherData: WeatherResponse) {
        locationLabel.text = weatherData.name
        weatherInfoLabel.text = "\(weatherData.main.temp)°C"
        weatherLabel.text = "\(weatherData.weather.first?.description ?? "")"
    }
}
