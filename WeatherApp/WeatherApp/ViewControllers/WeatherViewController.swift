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
import MapKit

final class WeatherViewController: UIViewController {

    private lazy var cityLabel: UILabel = createLabel(fontSize: 40)
    private lazy var weatherDescriptionLabel: UILabel = createLabel(fontSize: 20)
    private lazy var weatherIcon: UIImageView = UIImageView()
    private lazy var temperatureLabel: UILabel = createLabel(fontSize: 20)
    private lazy var maxTemparatureLabel: UILabel = createLabel(fontSize: 20)
    private lazy var minTemparatureLabel: UILabel = createLabel(fontSize: 20)
    private lazy var humidityLabel: UILabel = createLabel(fontSize: 20)
    
    private lazy var weatherCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        collectionView.layer.cornerRadius = 10
        collectionView.register(HourlyCollectionViewCell.self, forCellWithReuseIdentifier: "HourCell")
        return collectionView
    }()
    
    var location: Coord?
    private var viewModel:WeatherViewModel!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel = WeatherViewModel()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let layout = weatherCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: weatherCollectionView.frame.width/4, height: weatherCollectionView.frame.height)
            layout.invalidateLayout()
        }
    }
    
    private func createLabel(fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize)
        return label
    }
    
    private func configureUI() {
        view.backgroundColor = .black
        [cityLabel, weatherIcon, weatherDescriptionLabel, temperatureLabel, maxTemparatureLabel, minTemparatureLabel, humidityLabel,weatherCollectionView].forEach {
            view.addSubview($0)
        }
        
        cityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(100)
        }
        
        weatherIcon.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(cityLabel.snp.bottom).offset(10)
            make.width.height.equalTo(100)
        }
        
        weatherDescriptionLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(weatherIcon.snp.bottom).offset(10)
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
        
        weatherCollectionView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.top.equalTo(humidityLabel.snp.bottom).offset(10)
                make.height.equalTo(120)
            make.width.equalToSuperview().inset(50)
            }
    }
    
    private func bind() {
        let input = WeatherViewModel.Input(location: Observable.just(location ?? Coord(lon: nil, lat: nil)))
        let output = viewModel.transform(input: input)
        output.data.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] weatherResponse in
            self?.updateLabels(with: weatherResponse)
        }).disposed(by: disposeBag)
        output.icon.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] image in
            self?.weatherIcon.image = image
        }).disposed(by: disposeBag)
        
        
        output.hourlyData
            .flatMap { responseList -> Observable<[WeatherResponse]> in
                return Observable.from(optional: responseList.list)
            }
            .flatMap { weatherResponses in
                output.hourlyIcons
                    .map { iconImages in
                        return Array(zip(weatherResponses, iconImages))
                    }
            }
            .bind(to: weatherCollectionView.rx.items) { collectionView, row, item in
                    let indexPath = IndexPath(row: row, section: 0)
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourCell", for: indexPath) as! HourlyCollectionViewCell
                    let (weatherResponse, iconImage) = item
                cell.configure(weatherResponse: weatherResponse, iconImage: iconImage)
                    return cell
                }
                .disposed(by: disposeBag)



    }
    
    private func updateLabels(with weatherResponse: WeatherResponse) {
        cityLabel.text = weatherResponse.name
        weatherDescriptionLabel.text = weatherResponse.weather.first?.description
        temperatureLabel.text = String(format:"%.2f",weatherResponse.main.temp) + "℃"
        maxTemparatureLabel.text = "최고: "+String(format:"%.2f",weatherResponse.main.tempMax) + "℃"
        minTemparatureLabel.text = "최저: "+String(format:"%.2f",weatherResponse.main.tempMin) + "℃"
        humidityLabel.text = "humidity: "+String(format:"%.2f",weatherResponse.main.humidity) + "%"
    }
}

@available(iOS 17.0, *)
#Preview {
    WeatherViewController()
}
