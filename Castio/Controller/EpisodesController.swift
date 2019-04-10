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

    struct Episode {
        let title: String
    }
    var episodes = [Episode]()
    var podcast: Podcast? {
        didSet {
            navigationItem.title = podcast?.trackName
        }
    }
    
    fileprivate let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    fileprivate func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl else { return }
        let secureFeedUrl = feedUrl.contains("https") ? feedUrl : feedUrl.replacingOccurrences(of: "http", with: "https")
        guard let url = URL(string: secureFeedUrl) else { return }
        let parser = FeedParser(URL: url)
        parser.parseAsync { (result) in
            switch result {
            case let .rss(feed):
                var episodes = [Episode]()
                feed.items?.forEach({ (feedItem) in
                    var episode = Episode(title: feedItem.title ?? "")
                    episodes.append(episode)
                })
                self.episodes = episodes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                break
            case let .failure(error):
                print("Failed to parse feed:", error)
                break
            default:
                print("Found a feed.....")
            }
            
        }
        
    }
    
    fileprivate func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("")
    }
    
    
}
