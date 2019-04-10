//
//  PodcastCell.swift
//  Castio
//
//  Created by Xpress Integration on 4/8/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    
    @IBOutlet weak var podcastImg: UIImageView!
    
    @IBOutlet weak var trackNameLbl: UILabel!
    @IBOutlet weak var artistNameLbl: UILabel!
    @IBOutlet weak var episodeCountLbl: UILabel!
    
    var podcast: Podcast! {
        didSet {
            trackNameLbl.text = podcast.trackName
            artistNameLbl.text = podcast.artistName
            podcastImg.image = #imageLiteral(resourceName: "appicon")
            
            episodeCountLbl.text = "\(podcast.trackCount ?? 0) Episodes"
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            podcastImg.sd_setImage(with: url, completed: nil)
            
        }
    }
}
