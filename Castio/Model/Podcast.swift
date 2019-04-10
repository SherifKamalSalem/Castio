//
//  Podcast.swift
//  Castio
//
//  Created by Xpress Integration on 4/6/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation

struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
