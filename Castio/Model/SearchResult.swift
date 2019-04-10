//
//  SearchResult.swift
//  Castio
//
//  Created by Xpress Integration on 4/6/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation

struct SearchResult: Decodable {
    let resultCount: Int?
    let results: [Podcast]?
}
