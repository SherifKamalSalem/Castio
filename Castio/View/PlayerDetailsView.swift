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
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.transform = shrunkenTransform
        }
    }
    
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var durationLbl: UILabel!
    @IBOutlet weak var currentTimeLbl: UILabel!
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
    
    fileprivate let shrunkenTransform = CGAffineTransform(scaleX: 0.7, y: 0.7)
    
    @objc func handlePlayPause() {
        if player.timeControlStatus == .paused {
            playBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            player.play()
            enlargeEpisodeImage()
        } else {
            playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            player.pause()
            shrinkEpisodeImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        observeCurrentTime()
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        //there was a retain cycle in this closure because player has reference to itself
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeEpisodeImage()
        }
    }
    
    @objc func handleTapMaximize() {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: nil)
    }
    
    fileprivate func observeCurrentTime() {
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) {[weak self] (time) in
            self?.currentTimeLbl.text = time.toStringFormat()
            let durationTime = self?.player.currentItem?.duration
            self?.durationLbl.text = durationTime?.toStringFormat()
            self?.updateCurrentTimeSlider()
        }
    }
    
    fileprivate func updateCurrentTimeSlider() {
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        currentTimeSlider.value = Float(percentage)
    }
    
    @IBAction func dismissBtnTapped(_ sender: Any) {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.minimizePlayerDetails()
    }
    
    @IBAction func handleCurrentTimeSliderChanged(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        player.seek(to: seekTime)
    }
    
    @IBAction func handleRewindBtnTapped(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleFastForwordBtnTapped(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    fileprivate func seekToCurrentTime(delta: Int64) {
        let fifteenSeconds = CMTimeMake(value: delta, timescale: 1)
        let seekTime = CMTimeAdd(player.currentTime(), fifteenSeconds)
        player.seek(to: seekTime)
    }
    
    static func initFromNib() -> PlayerDetailsView {
        let playerDetailsView = Bundle.main.loadNibNamed("PlayerDetailsView", owner: self, options: nil)?.first as! PlayerDetailsView
        return playerDetailsView
    }
    
    @IBAction func handleVolumeSliderChanged(_ sender: UISlider) {
        player.volume = sender.value
    }
    
    fileprivate func enlargeEpisodeImage() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = .identity
        })
    }
    
    fileprivate func shrinkEpisodeImage() {
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.episodeImageView.transform = self.shrunkenTransform
        })
    }
}
