//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by 이다연 on 2/1/24.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController/*, UISearchBarDelegate, UISearchResultsUpdating*/ {
//    func updateSearchResults(for searchController: UISearchController) {
//        <#code#>
//    }
//    
    
    private let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.backgroundColor = .white
//        let searchController = UISearchController(searchResultsController: nil)
//        searchController.searchBar.placeholder = "검색(placeholder)"
//        // 내비게이션 바는 항상 표출되도록 설정
//        searchController.hidesNavigationBarDuringPresentation = false
//        /// updateSearchResults(for:) 델리게이트를 사용을 위한 델리게이트 할당
//        searchController.searchResultsUpdater = self
//        /// 뒷배경이 흐려지지 않도록 설정
//        searchController.obscuresBackgroundDuringPresentation = false
//        
//        navigationItem.searchController = searchController
//        navigationItem.hidesSearchBarWhenScrolling = false
        
    }
    
}
