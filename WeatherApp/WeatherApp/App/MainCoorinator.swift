//
//  MainCoorinator.swift
//  WeatherApp
//
//  Created by 이다연 on 2/1/24.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }
    
    func start()
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let pageViewController = PageViewController(coordinator: self)
        navigationController.pushViewController(pageViewController, animated: true)
    }
}
