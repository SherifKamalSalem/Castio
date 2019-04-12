//
//  APIService.swift
//  Castio
//
//  Created by Xpress Integration on 4/7/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    static let shared = APIService()
    let baseiTunesSearchURL = "https://itunes.apple.com/search"
    
    func fetchEpisodes(feedUrl: String, completionHandler: @escaping([Episode]) -> ()) {
        guard let url = URL(string: feedUrl.toSecureHTTPS()) else { return }
        DispatchQueue.global(qos: .background).async {
            let parser = FeedParser(URL: url)
            parser.parseAsync { (result) in
                if let err = result.error {
                    print("Failed to parse XML feed: ", err)
                    return
                }
                guard let feed = result.rssFeed else { return }
                let episodes = feed.toEpisodes()
                completionHandler(episodes)
            }
        }
    }
    
    func fetchPodcasts(searchText: String, completionHandler: @escaping ([Podcast]) -> ()) {
        let parameters = ["term" : searchText, "media" : "podcast"]
        AF.request(baseiTunesSearchURL, method: .get, parameters: parameters, encoding: URLEncoding.default).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("Failed to connect itunes API", err)
                return
            }

            guard let data = dataResponse.data else { return }
            let dummyString = String(data: data, encoding: .utf8)
            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                print("result \(searchResult)")
                completionHandler(searchResult.results!)
            } catch let decodeError {
                print("Failed to decode: ", decodeError)
            }
        }
    }
}
