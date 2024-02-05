//
//  PageViewController.swift
//  WeatherApp
//
//  Created by 이다연 on 2/1/24.
//

import UIKit

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    weak var coordinator: MainCoordinator?
    var pages: [UIViewController] = []
    var pageControl = UIPageControl()

    init(coordinator: MainCoordinator) {
        self.coordinator = coordinator
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        // 페이지 뷰 컨트롤러를 생성하고 배열에 추가합니다.
        let page1 = WeatherViewController()
        page1.location = "current location"
        let page2 = SearchViewController()
        pages.append(page1)
        pages.append(page2)

        if let firstPage = pages.first {
            setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        }
        
        configurePageControl()
    }

    func configurePageControl() {
        pageControl.frame = CGRect(x: 0, y: UIScreen.main.bounds.maxY - 100, width: UIScreen.main.bounds.width, height: 50)
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        view.addSubview(pageControl)
        view.bringSubviewToFront(pageControl)
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

