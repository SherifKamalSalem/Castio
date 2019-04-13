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
import MediaPlayer

class PlayerDetailsView: UIView {
    
    @IBOutlet weak var episodeImageView: UIImageView! {
        didSet {
            episodeImageView.transform = shrunkenTransform
        }
    }
    
    @IBOutlet weak var miniPlayerEpisodeTitleLbl: UILabel!
    @IBOutlet weak var miniPlayerImageView: UIImageView!
    
    @IBOutlet weak var miniPlayerPauseBtn: UIButton! {
        didSet {
            miniPlayerPauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        }
    }
    @IBOutlet weak var miniPlayerView: UIView!
    @IBOutlet weak var maximizeStackView: UIStackView!
    
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
    
    var playlistEpisodes = [Episode]()
    
    var episode: Episode! {
        didSet {
            playEpisode()
            guard let url = URL(string: episode.imageUrl?.toSecureHTTPS() ?? "") else { return }
            episodeImageView.sd_setImage(with: url)
            miniPlayerImageView.sd_setImage(with: url) { (image, _, _, _) in
                guard let image = image else { return }
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                let artWork = MPMediaItemArtwork(boundsSize: image.size, requestHandler: { (_) -> UIImage in
                    return image
                })
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artWork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
            episodeTitle.text = episode.title
            miniPlayerEpisodeTitleLbl.text = episode.title
            autherLbl.text = episode.auther ?? ""
            
            setupNowPlayingInfo()
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
    
    var panGesture: UIPanGestureRecognizer!
    
    @objc func handlePlayPause() {
        if player.timeControlStatus == .paused {
            playBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            player.play()
            enlargeEpisodeImage()
        } else {
            playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            player.pause()
            shrinkEpisodeImage()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupRemoteControl()
        setupAudioSesstion()
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        observeCurrentTime()
        
        observeBoundaryTime()
    }
    
    fileprivate func observeBoundaryTime() {
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        //there was a retain cycle in this closure because player has reference to itself
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeEpisodeImage()
            self?.setupLockScreenDuration()
        }
    }
    
    fileprivate func setupLockScreenDuration() {
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
    }
    
    //for playing audio in background mode
    fileprivate func setupAudioSesstion() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch let sessionError {
            print("Failed to activate audio session:", sessionError)
        }
    }
    
    //for controlling the out widget for play / pause audio without the need to open the app
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.playBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            self.setupElapsedTime()
            return .success
        }
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.playBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            self.miniPlayerPauseBtn.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(handleNextTrack))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(handlePreviousTrack))
    }
    
    @objc func handlePreviousTrack() {
        if playlistEpisodes.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playlistEpisodes.firstIndex { (ep) -> Bool in
            return ep.title == episode.title && ep.auther == episode.auther
        }
        guard let index = currentEpisodeIndex else { return }
        let prevEpisode: Episode
        if index == 0 {
            prevEpisode = playlistEpisodes.last!
        } else {
            prevEpisode = playlistEpisodes[index  - 1]
        }
        
        self.episode = prevEpisode
    }
    
    @objc func handleNextTrack() {
        if playlistEpisodes.count == 0 {
            return
        }
        
        let currentEpisodeIndex = playlistEpisodes.firstIndex { (ep) -> Bool in
            return ep.title == episode.title && ep.auther == episode.auther
        }
        guard let index = currentEpisodeIndex else { return }
        let nextEpisode: Episode
        if index == playlistEpisodes.count - 1 {
            nextEpisode = playlistEpisodes[0]
        } else {
            nextEpisode = playlistEpisodes[index + 1]
        }
        
        self.episode = nextEpisode
    }
    
    fileprivate func setupElapsedTime() {
        let elapsedTime = CMTimeGetSeconds(player.currentTime())
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTime
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .changed {
            handlePanChanged()
        } else if gesture.state == .ended {
            handlePanEnded()
        }
    }
    
    fileprivate func handlePanChanged() {
        let translation = panGesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        miniPlayerView.alpha = 1 + translation.y / 200
        maximizeStackView.alpha = -translation.y / 200
    }
    
    fileprivate func handlePanEnded() {
        let translation = panGesture.translation(in: self.superview)
        let velocity = panGesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
                mainTabBarController?.maximizePlayerDetails(episode: nil)
                self.panGesture.isEnabled = false
            } else {
                self.miniPlayerView.alpha = 1
                self.maximizeStackView.alpha = 0
            }
        })
    }
    
    @objc func handleTapMaximize() {
        let mainTabBarController = UIApplication.shared.keyWindow?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(episode: nil)
        panGesture.isEnabled = false
    }
    
    fileprivate func setupNowPlayingInfo() {
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode.auther
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
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
        panGesture.isEnabled = true
    }
    
    @IBAction func handleCurrentTimeSliderChanged(_ sender: Any) {
        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: Int32(NSEC_PER_SEC))
        MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = seekTimeInSeconds
        player.seek(to: seekTime)
    }
    
    @IBAction func handleRewindBtnTapped(_ sender: Any) {
        seekToCurrentTime(delta: -15)
    }
    
    @IBAction func handleFastForwordBtnTapped(_ sender: Any) {
        seekToCurrentTime(delta: 15)
    }
    
    @IBAction func handleMiniPlayerPauseBtnTapped(_ sender: Any) {
        
    }
    
    @IBAction func handleMiniPlayerForwordBtnTapped(_ sender: Any) {
        
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
