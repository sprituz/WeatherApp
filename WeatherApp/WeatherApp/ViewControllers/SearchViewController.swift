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
    
    lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.keyboardDismissMode = .onDrag
        view.backgroundColor = .white
        return view
    }()
    
    private var viewModel:SearchViewModel!
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = SearchViewModel()
        view.backgroundColor = .white
        title = "도시 검색"
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { make in
            make.leading.equalTo(view.snp.leading)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
            make.trailing.equalTo(view.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
        }
        
        tableView.rx.modelSelected(Location.self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] item in
                let weatherViewController = WeatherViewController()
                weatherViewController.location = item.coord
                weatherViewController.shouldShowAddButton = true
                self?.present(weatherViewController, animated: true)
            })
            .disposed(by: disposeBag)
        
        setupSearchController()
        bind()
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
    
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func bind() {
        let searchController = navigationItem.searchController
        // searchBar의 text 변화를 감지하고, 이를 ViewModel의 input으로 바인드
        let input = SearchViewModel.Input(text: searchController?.searchBar.rx.text.orEmpty.asObservable() ?? .empty())
        
        let output = viewModel.transform(input: input)
        
        // ViewModel의 output을 tableView에 바인드
        output.data
            .observe(on: MainScheduler.instance)
            .bind(to: tableView.rx.items(cellIdentifier: "cell")) { (index, element: Location, cell) in
                cell.textLabel?.text = element.name + ", " + element.country
                cell.backgroundColor = .white
                cell.textLabel?.textColor = .black
                cell.selectionStyle = .none
            }
            .disposed(by: disposeBag)
    }
}

@available(iOS 17.0, *)
#Preview {
    SearchViewController()
}
