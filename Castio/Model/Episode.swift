//
//  Episode.swift
//  Castio
//
//  Created by Xpress Integration on 4/10/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation
import FeedKit

struct Episode {
    var title: String
    var pubDate: Date
    var description: String
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.description ?? ""
    }
}
