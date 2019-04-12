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
    
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.tintColor = #colorLiteral(red: 0.8392156863, green: 0, blue: 1, alpha: 1)
        
        setupViewControllers()
        setupPlayerDetailsView()
        
    }
    let playerDetailsView = PlayerDetailsView.initFromNib()
    
    fileprivate func setupPlayerDetailsView() {
        view.insertSubview(playerDetailsView, belowSubview: tabBar)
        playerDetailsView.translatesAutoresizingMaskIntoConstraints = false
        maximizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        minimizedTopAnchorConstraint = playerDetailsView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        
        playerDetailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        playerDetailsView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        playerDetailsView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    @objc func minimizePlayerDetails() {
        maximizedTopAnchorConstraint.isActive = false
        minimizedTopAnchorConstraint.isActive = true
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = .identity
        })
    }
    
    func maximizePlayerDetails(episode: Episode?) {
        maximizedTopAnchorConstraint.isActive = true
        maximizedTopAnchorConstraint.constant = 0
        minimizedTopAnchorConstraint.isActive = false
        if episode != nil {
            playerDetailsView.episode = episode
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
            self.tabBar.transform = CGAffineTransform(translationX: 0, y: 100)
        })
    }
    
    fileprivate func setupViewControllers() {
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
