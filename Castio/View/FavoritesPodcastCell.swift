//
//  FavoritesPodcastCell.swift
//  Castio
//
//  Created by Xpress Integration on 4/13/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import UIKit

class FavoritesPodcastCell: UICollectionViewCell {

    let autherImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        iv.clipsToBounds = true
        return iv
    }()
    
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()
    
    var podcast: Podcast! {
        didSet {
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            guard let imageUrl = podcast.artworkUrl600 else { return }
            let url = URL(string: imageUrl)
            autherImageView.sd_setImage(with: url)
        }
    }
    
    fileprivate func stylizeUI() {
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        artistNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        artistNameLabel.textColor = .lightGray
    }
    
    fileprivate func setupViews() {
        
        let stackView = UIStackView(arrangedSubviews: [autherImageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        autherImageView.heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        stylizeUI()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
