//
//  MainTabBarController.swift
//  Castio
//
//  Created by Xpress Integration on 4/6/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation
import UIKit


class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = #colorLiteral(red: 0.8392156863, green: 0, blue: 1, alpha: 1)
        
        
        viewControllers = [
            generateNavControllers(for: ViewController(), title: "Favorites", image: #imageLiteral(resourceName: "favorite")),
            generateNavControllers(for: PodcastsSearchController(), title: "Search", image: #imageLiteral(resourceName: "search")),
            generateNavControllers(for: ViewController(), title: "Download", image: #imageLiteral(resourceName: "download"))
        ]
    }
    
    fileprivate func generateNavControllers(for rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.navigationBar.prefersLargeTitles = true
        navController.tabBarItem.title = title
        rootViewController.navigationItem.title = title
        navController.tabBarItem.image = image
        return navController
    }
}
