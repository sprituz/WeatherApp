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
    
    //추가 버튼 보여줄지 말지
    var shouldShowAddButton = false
    
    let addButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        return button
    }()
        
    
    private lazy var cityLabel: UILabel = createLabel(fontSize: 40, fontWeight: .bold)
    private lazy var weatherDescriptionLabel: UILabel = createLabel(fontSize: 20, fontWeight: .bold)
    private lazy var weatherIcon: UIImageView = UIImageView()
    private lazy var temperatureLabel: UILabel = createLabel(fontSize: 20, fontWeight: .regular)
    private lazy var humidityLabel: UILabel = createLabel(fontSize: 20, fontWeight: .regular)
    
    private lazy var hourlyCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        collectionView.layer.cornerRadius = 10
        collectionView.register(HourlyCollectionViewCell.self, forCellWithReuseIdentifier: "HourCell")
        return collectionView
    }()
    
    private lazy var dailyCollectionView: UICollectionView = {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        collectionView.layer.cornerRadius = 10
        collectionView.register(DailyCollectionViewCell.self, forCellWithReuseIdentifier: "DailyCell")
        return collectionView
    }()
    
    let scrollView = UIScrollView()
    
    // 위치
    var location: Coord?
    
    private var viewModel:WeatherViewModel!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = WeatherViewModel()
        configureUI()
        bind()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let hourlyLayout = hourlyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            hourlyLayout.itemSize = CGSize(width: hourlyCollectionView.frame.width/4, height: hourlyCollectionView.frame.height)
            hourlyLayout.invalidateLayout()
        }
        
        if let dailyLayout = dailyCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            dailyLayout.itemSize = CGSize(width: dailyCollectionView.frame.width, height: dailyCollectionView.frame.height/6)
            dailyLayout.invalidateLayout()
        }
    }
    
    private func createLabel(fontSize: CGFloat, fontWeight: UIFont.Weight) -> UILabel {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        return label
    }
    
    private func configureUI() {
        
        view.addSubview(scrollView)
        view.addSubview(addButton)
        
        if shouldShowAddButton {
            addButton.isHidden = false
        } else {
            addButton.isHidden = true
        }
        
        
        scrollView.snp.makeConstraints { make in
            make.width.height.leading.trailing.equalToSuperview()
        }
        
        view.backgroundColor = .black
        [cityLabel, weatherIcon, weatherDescriptionLabel, temperatureLabel, humidityLabel,hourlyCollectionView,dailyCollectionView].forEach {
            scrollView.addSubview($0)
        }
        
        addButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.top.equalToSuperview().inset(10)
            make.trailing.equalToSuperview().inset(10)
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
        
        humidityLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(temperatureLabel.snp.bottom).offset(10)
        }
        
        hourlyCollectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(humidityLabel.snp.bottom).offset(10)
            make.height.equalTo(120)
            make.width.equalToSuperview().inset(50)
        }
        
        dailyCollectionView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(hourlyCollectionView.snp.bottom).offset(10)
            make.height.equalTo(400)
            make.width.equalToSuperview().inset(50)
            make.bottom.equalToSuperview().inset(50)
        }
    }
    
    private func bind() {
        
        addButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                // 화면 닫기 동작 구현
                self?.dismiss(animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
        
        let input = WeatherViewModel.Input(location: Observable.just(location ?? Coord(lon: nil, lat: nil)),
                                           addButtonTapped: addButton.rx.tap.asObservable())
        
        let output = viewModel.transform(input: input)
        
        output.data.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] weatherResponse in
            self?.updateLabels(with: weatherResponse)
        }).disposed(by: disposeBag)
        
        output.icon.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] image in
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
            .bind(to: hourlyCollectionView.rx.items) { collectionView, row, item in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HourCell", for: indexPath) as! HourlyCollectionViewCell
                let (weatherResponse, iconImage) = item
                cell.configure(weatherResponse: weatherResponse, iconImage: iconImage)
                return cell
            }
            .disposed(by: disposeBag)
        
        output.dailyData
            .flatMap { weatherResponses in
                output.dailyIcons
                    .map { iconImages in
                        return Array(zip(weatherResponses, iconImages))
                    }
            }
            .bind(to: dailyCollectionView.rx.items) { collectionView, row, item in
                let indexPath = IndexPath(row: row, section: 0)
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DailyCell", for: indexPath) as! DailyCollectionViewCell
                let (weatherResponse, iconImage) = item
                cell.configure(weatherResponse: weatherResponse, iconImage: iconImage)
                return cell
            }
            .disposed(by: disposeBag)
        
        // 위치 UserDefaults에 있으면 추가버튼 숨기기
        output.shouldShowAddButton.observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] shouldShow in
                self?.addButton.isHidden = !shouldShow
            })
            .disposed(by: disposeBag)
        
    }
    
    private func updateLabels(with weatherResponse: WeatherResponse) {
        cityLabel.text = weatherResponse.name
        weatherDescriptionLabel.text = weatherResponse.weather.first?.description
        temperatureLabel.text = String(format:"%.2f",weatherResponse.main.temp) + "℃"
        humidityLabel.text = "humidity: "+String(format:"%.2f",weatherResponse.main.humidity) + "%"
    }
}

@available(iOS 17.0, *)
#Preview {
    WeatherViewController()
}
