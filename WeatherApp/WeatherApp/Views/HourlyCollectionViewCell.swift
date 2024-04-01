//
//  HourlyCollectionViewCell.swift
//  WeatherApp
//
//  Created by 이다연 on 2/19/24.
//

import UIKit
import RxSwift
import SnapKit

class HourlyCollectionViewCell: UICollectionViewCell {
    
    lazy var timeLabel: UILabel = createLabel(fontSize: 15, fontWeight: .bold)
    
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
        weatherIcon.image = nil
        timeLabel.text = nil
        temperatureLabel.text = nil
    }
    
    
    private func setUI() {
        
        contentView.addSubview(timeLabel)
        contentView.addSubview(weatherIcon)
        contentView.addSubview(temperatureLabel)
        
        timeLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(10)
        }
        
        weatherIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.height.equalTo(40)
            make.top.equalTo(timeLabel.snp.bottom).offset(5)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.height.equalTo(20)
            make.top.equalTo(weatherIcon.snp.bottom).offset(5)
        }
    }
    
    func configure(weatherResponse: WeatherResponse, iconImage: UIImage) {
        temperatureLabel.text = "\(weatherResponse.main.temp)°C" // 기온 설정
        weatherIcon.image = iconImage // 아이콘 이미지 설정
        timeLabel.text = weatherResponse.dt.fromTimestamp(format: "HH:mm")
    }
    
}


#Preview {
    HourlyCollectionViewCell()
}
