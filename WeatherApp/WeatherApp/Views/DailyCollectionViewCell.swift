//
//  DailyCollectionViewCell.swift
//  WeatherApp
//
//  Created by 이다연 on 2/21/24.
//

import UIKit
import RxSwift
import SnapKit

class DailyCollectionViewCell: UICollectionViewCell {
    
    lazy var dateLabel: UILabel = createLabel(fontSize: 15, fontWeight: .bold)
    
    lazy var weatherIcon: UIImageView = UIImageView()
    
    lazy var temperatureLabel: UILabel = createLabel(fontSize: 15, fontWeight: .regular)
    
    private func createLabel(fontSize: CGFloat, fontWeight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        return label
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
        weatherIcon.image = nil
        temperatureLabel.text = nil
    }
    
    
    private func setUI() {
        

        contentView.addSubview(dateLabel)
        contentView.addSubview(weatherIcon)
        contentView.addSubview(temperatureLabel)

        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
            make.leading.equalTo(10)
        }
        
        weatherIcon.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(50)
            make.leading.equalTo(dateLabel.snp.trailing).offset(10)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.height.equalTo(60)
            make.leading.equalTo(weatherIcon.snp.trailing).offset(10)
        }
    }
    
    func configure(weatherResponse: WeatherResponse, iconImage: UIImage) {
        dateLabel.text = weatherResponse.dt.fromTimestamp(format: "MM/dd")
        weatherIcon.image = iconImage // 아이콘 이미지 설정
        temperatureLabel.text = "\(weatherResponse.main.tempMin)°C / \(weatherResponse.main.tempMax)°C" // 기온 설정
    }
    
}

