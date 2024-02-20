//
//  PageViewController.swift
//  WeatherApp
//
//  Created by 이다연 on 2/1/24.
//

import UIKit
import RxSwift

final class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pages: [UIViewController] = []
    var pageControl = UIPageControl()
    
    private lazy var mapButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        if let image = UIImage(systemName: "map") {
            button.setImage(image, for: .normal)
        }
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        if let image = UIImage(systemName: "list.bullet") {
            button.setImage(image, for: .normal)
        }
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
    }()
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        let page1 = WeatherViewController()
        page1.location = Coord(lon: nil, lat: nil)
        pages.append(page1)
        
        
        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        configurePageControl()
        
    }
    
    
    func configurePageControl() {
        pageControl.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: UIScreen.main.bounds.width, height: 50)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        let image = UIImage(systemName: "location.fill")
        pageControl.setIndicatorImage(image, forPage: 0)
        view.addSubview(pageControl)
        view.bringSubviewToFront(pageControl)
        
        pageControl.addSubview(mapButton)
        pageControl.addSubview(searchButton)
        
        mapButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(40)
            make.centerY.equalToSuperview()
        }
        
        searchButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(40)
            make.centerY.equalToSuperview()
        }
        
        searchButton.rx.tap
            .subscribe(onNext: { [weak self] _ in
                let searchVC = SearchViewController()
                self?.navigationController?.pushViewController(searchVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let previousIndex = index - 1
        if previousIndex < 0 {
            return nil
        }
        pageControl.currentPage = previousIndex
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController) else { return nil }
        let nextIndex = index + 1
        if nextIndex == pages.count {
            return nil
        }
        pageControl.currentPage = nextIndex
        return pages[nextIndex]
    }
    
}

