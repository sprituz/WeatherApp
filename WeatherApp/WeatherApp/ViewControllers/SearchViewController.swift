//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by 이다연 on 2/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class SearchViewController: UIViewController {
    
    var text: String = ""
    
    lazy var savedWeatherTableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.keyboardDismissMode = .onDrag
        view.backgroundColor = .white
        return view
    }()
    
    lazy var searchResultTableView: UITableView = {
        let view = UITableView()
        view.register(SavedWeatherTableViewCell.self, forCellReuseIdentifier: "cell")
        view.keyboardDismissMode = .onDrag
        view.backgroundColor = .white
        return view
    }()
    
    private var viewModel:SearchViewModel!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SearchViewModel()
        configureUI()
        setupSearchController()
        bind()
    }
    
    private func configureUI() {
        
        view.backgroundColor = .white
        title = "Weather"
        
        view.addSubview(savedWeatherTableView)
        view.addSubview(searchResultTableView)
        
        savedWeatherTableView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        searchResultTableView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        searchResultTableView.rx.modelSelected(Location.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                let weatherViewController = WeatherViewController()
                weatherViewController.location = item.coord
                weatherViewController.shouldShowAddButton = true
                self?.present(weatherViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        searchResultTableView.isHidden = true
        savedWeatherTableView.isHidden = false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.searchController = nil
    }
    
    
    private func setupSearchController() {
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Enter city name"
        // 내비게이션 바는 항상 표출되도록 설정
        searchController.hidesNavigationBarDuringPresentation = false
        /// 뒷배경이 흐려지지 않도록 설정
        searchController.obscuresBackgroundDuringPresentation = false
        //타임아웃 해결
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.spellCheckingType = .no
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func bind() {
        let searchController = navigationItem.searchController
        
        // searchBar의 text 변화를 감지하고, 이를 ViewModel의 input으로 바인드
        let searchTextObservable = searchController?.searchBar.rx.text.orEmpty.asObservable() ?? .empty()
        let deleteTrigger = savedWeatherTableView.rx.modelDeleted(Coord.self).asObservable()
        
        let input = SearchViewModel.Input(text:searchTextObservable ,deleteTrigger: deleteTrigger)
        
        let output = viewModel.transform(input: input)
        
        // ViewModel의 output을 tableView에 바인드
        output.data
            .observe(on: MainScheduler.instance)
            .bind(to: searchResultTableView.rx.items(cellIdentifier: "cell")) { (index, element: Location, cell) in
                cell.textLabel?.text = element.name + ", " + element.country
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        output.savedWeatherData
            .observe(on: MainScheduler.instance)
            .bind(to: savedWeatherTableView.rx.items(cellIdentifier: "cell")) { (index, element: WeatherResponse, cell) in
                if let cityName = element.name {
                            cell.textLabel?.text = cityName
                        }
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        searchController?.searchBar.rx.text.orEmpty
            .distinctUntilChanged() // 연속된 중복 값을 필터링
            .subscribe(onNext: { [unowned self] query in
                if query.isEmpty {
                    // 검색창이 비어 있을 때
                    self.searchResultTableView.isHidden = true
                    self.savedWeatherTableView.isHidden = false
                } else {
                    // 검색창에 텍스트가 있을 때
                    self.searchResultTableView.isHidden = false
                    self.savedWeatherTableView.isHidden = true
                }
            })
            .disposed(by: disposeBag)

    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
