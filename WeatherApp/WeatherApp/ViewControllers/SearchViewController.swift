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
import MapKit

final class SearchViewController: UIViewController {
    
    var text: String = ""
    
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var savedWeatherTableView: UITableView = {
        let view = UITableView()
        view.register(SavedWeatherTableViewCell.self, forCellReuseIdentifier: "cell")
        view.keyboardDismissMode = .onDrag
        view.backgroundColor = .black
        return view
    }()
    
    lazy var searchResultTableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.keyboardDismissMode = .onDrag
        view.backgroundColor = .black
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
        
        view.backgroundColor = .black
        title = "Weather"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.barTintColor = .black
        navigationController?.navigationBar.tintColor = .gray
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        
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
        
        
        searchResultTableView.isHidden = true
        savedWeatherTableView.isHidden = false
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        navigationItem.searchController = nil
    }
    
    
    private func setupSearchController() {
        
        searchController.searchBar.placeholder = "Enter city name"
        // 내비게이션 바는 항상 표출되도록 설정
        searchController.hidesNavigationBarDuringPresentation = false
        //검색할때 뒷배경 흐려지게
        searchController.obscuresBackgroundDuringPresentation = false
        //맞춤법 수정 끄기
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.spellCheckingType = .no
        
        searchController.searchBar.barTintColor = .gray
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func bind() {
        let searchController = navigationItem.searchController
        
        // searchBar의 text 변화를 감지하고, 이를 ViewModel의 input으로 바인드
        let searchTextObservable = searchController?.searchBar.rx.text.orEmpty.asObservable() ?? .empty()
        let deleteTrigger = savedWeatherTableView.rx.modelDeleted((Coord,WeatherResponse).self).asObservable()
        
        
        let selectedLocationObservable = searchResultTableView.rx.modelSelected(MKLocalSearchCompletion.self).asObservable()
        
        //검색 활성화시의 observable
        let searchActiveObservable = searchController?.rx.isActive
        
        let input = SearchViewModel.Input(searchQuery: searchTextObservable, selectedLocation: selectedLocationObservable, deleteTrigger: deleteTrigger)
        let output = viewModel.transform(input: input)
        
        
        searchController?.searchBar.rx.text.orEmpty
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
        
        
        
        output.savedWeatherData
            .observe(on: MainScheduler.instance)
            .bind(to: savedWeatherTableView.rx.items(cellIdentifier: "cell", cellType: SavedWeatherTableViewCell.self)) { (index, element: (Coord, WeatherResponse), cell) in
                cell.configure(with: element.1)
                cell.backgroundColor = .black
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
        
        output.searchResults
            .observe(on: MainScheduler.instance)
            .bind(to: searchResultTableView.rx.items(cellIdentifier: "cell")) { row, completion, cell in
                cell.textLabel?.text = completion.title
                cell.detailTextLabel?.text = completion.subtitle
                cell.backgroundColor = .black
            }
            .disposed(by: disposeBag)
        
        output.coordinate
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                let weatherViewController = WeatherViewController()
                weatherViewController.location = Coord(lon: item.longitude, lat: item.latitude)
                weatherViewController.shouldShowAddButton = true
                self?.present(weatherViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
