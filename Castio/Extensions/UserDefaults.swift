//
//  UserDefaults.swift
//  Castio
//
//  Created by Xpress Integration on 4/15/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadEpisodeKey = "downloadEpisodeKey"
    
    func downloadEpisode(episode: Episode) {
        do {
            var episodes = downloadedEpisodes()
            episodes.append(episode)
            let data = try JSONEncoder().encode(episodes)
             UserDefaults.standard.set(data, forKey: UserDefaults.downloadEpisodeKey)
        } catch let encodeError {
            print("Failed to encode episode", encodeError)
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        guard let episodeData = data(forKey: UserDefaults.downloadEpisodeKey) else { return [] }
        do {
            let episodes = try JSONDecoder().decode([Episode].self, from: episodeData)
            return episodes
        } catch let decodeError {
            print("Failed to decode episode", decodeError)
        }
        return []
    }
    
    func savedPodcasts() -> [Podcast] {
        
        guard let savedPodcastData = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        do {
            guard let savedPodcasts = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedPodcastData) as? [Podcast] else { return [] }
            return savedPodcasts
            
        } catch let error {
            print("Failed to archive podcast: ", error)
        }
        return []
    }
}
