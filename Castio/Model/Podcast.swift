//
//  Podcast.swift
//  Castio
//
//  Created by Xpress Integration on 4/6/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation

class Podcast: NSObject, Decodable, NSCoding {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(trackName ?? "", forKey: Constants.trackNameKey)
        aCoder.encode(artistName ?? "", forKey: Constants.artistNameKey)
        aCoder.encode(artworkUrl600 ?? "", forKey: Constants.artworkUrl600Key)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.trackName = aDecoder.decodeObject(forKey: Constants.trackNameKey) as? String
        self.artistName = aDecoder.decodeObject(forKey: Constants.artistNameKey) as? String
        self.artworkUrl600 = aDecoder.decodeObject(forKey: Constants.artworkUrl600Key) as? String
    }
}
