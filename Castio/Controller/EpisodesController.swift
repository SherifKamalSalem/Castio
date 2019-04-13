//
//  EpisodesController.swift
//  Castio
//
//  Created by Xpress Integration on 4/10/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {

    var episodes = [Episode]()
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
            fetchEpisodes()
        }
    }
    
    fileprivate let cellId = "cellId"
    let favoritedPodcastKey = "favoritedPodcastKey"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBarButtons()
    }
    
    fileprivate func setupNavigationBarButtons() {
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite)),
            UIBarButtonItem(title: "Fetch", style: .plain, target: self, action: #selector(handleFetchSavedPodcasts))
        ]
    }
    
    @objc fileprivate func handleSaveFavorite() {
        guard let podcast = podcast else { return }
        do {
           let data = try NSKeyedArchiver.archivedData(withRootObject: podcast, requiringSecureCoding: false)
            UserDefaults.standard.set(data, forKey: favoritedPodcastKey)
        } catch let error {
            print("Failed to archive podcast: ", error)
        }
    }
    
    @objc fileprivate func handleFetchSavedPodcasts() {
        guard let data = UserDefaults.standard.data(forKey: favoritedPodcastKey) else { return }
        do {
            let podcast = try NSKeyedUnarchiver.unarchivedObject(ofClass: Podcast.self, from: data)
        } catch let error {
            print("Failed to unarchive podcast: ", error)
        }
    }

    fileprivate func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl else { return }
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            self.episodes = episodes
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func setupTableView() {
        let episodeNib = UINib(nibName: "EpisodeCell", bundle: nil)
        tableView.register(episodeNib, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicatorView = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicatorView.color = .darkGray
        activityIndicatorView.startAnimating()
        return activityIndicatorView
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200 : 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? EpisodeCell else { return UITableViewCell() }
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        let episode = episodes[indexPath.row]
        mainTabBarController?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.episodes)
    }
    
}
