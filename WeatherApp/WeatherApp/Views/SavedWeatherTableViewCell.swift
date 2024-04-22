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
    
    private let weatherIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let weatherInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.darkGray
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(locationLabel)
        contentView.addSubview(weatherIconImageView)
        contentView.addSubview(weatherInfoLabel)
        
        locationLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalTo(weatherIconImageView.snp.leading).offset(-8)
        }
        
        weatherIconImageView.snp.makeConstraints { make in
            make.centerY.equalTo(locationLabel)
            make.trailing.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        weatherInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(locationLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with weatherData: WeatherResponse, icon: UIImage?) {
        locationLabel.text = weatherData.name
        weatherInfoLabel.text = "\(weatherData.main.temp)°C"
        weatherIconImageView.image = icon
    }
}

