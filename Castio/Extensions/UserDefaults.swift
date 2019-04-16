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
