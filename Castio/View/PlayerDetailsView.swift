//
//  PlayerDetailsView.swift
//  Castio
//
//  Created by Xpress Integration on 4/11/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage
import AVKit

class PlayerDetailsView: UIView {
    
    @IBOutlet weak var episodeImageView: UIImageView!
    
    @IBOutlet weak var autherLbl: UILabel!
    @IBOutlet weak var episodeTitle: UILabel!
    @IBOutlet weak var playBtn: UIButton! {
        didSet {
            playBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            playBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    
    var episode: Episode! {
        didSet {
            playEpisode()
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            episodeTitle.text = episode.title
            autherLbl.text = episode.auther ?? ""
        }
    }
    
    let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    fileprivate func playEpisode() {
        guard let url = URL(string: episode.streamUrl) else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
    }
    
    @objc func handlePlayPause() {
        if player.timeControlStatus == .paused {
            playBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            player.play()
        } else {
            playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            player.pause()
        }
    }
    
    @IBAction func dismissBtnTapped(_ sender: Any) {
        self.removeFromSuperview()
    }
}
