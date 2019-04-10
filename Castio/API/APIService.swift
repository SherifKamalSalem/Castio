//
//  APIService.swift
//  Castio
//
//  Created by Xpress Integration on 4/7/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation
import Alamofire

class APIService {
    static let shared = APIService()
    let baseiTunesSearchURL = "https://itunes.apple.com/search"
    
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
