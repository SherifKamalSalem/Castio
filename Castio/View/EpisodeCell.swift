//
//  EpisodeCell.swift
//  Castio
//
//  Created by Xpress Integration on 4/10/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import UIKit

class EpisodeCell: UITableViewCell {

    @IBOutlet weak var episodeImg: UIImageView!
    @IBOutlet weak var pubDateLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel! {
        didSet {
            titleLbl.numberOfLines = 2
        }
    }
    @IBOutlet weak var descriptionLbl: UILabel! {
        didSet {
            descriptionLbl.numberOfLines = 2
        }
    }
    
    var episode: Episode! {
        didSet {
            titleLbl.text = episode.title
            descriptionLbl.text = episode.description
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM dd, yyyy"
            pubDateLbl.text = dateFormatter.string(from: episode.pubDate)
            let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "")
            episodeImg.sd_setImage(with: url)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
