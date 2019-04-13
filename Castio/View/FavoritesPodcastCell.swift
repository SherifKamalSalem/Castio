//
//  FavoritesPodcastCell.swift
//  Castio
//
//  Created by Xpress Integration on 4/13/19.
//  Copyright © 2019 Xpress Integration. All rights reserved.
//

import UIKit

class FavoritesPodcastCell: UICollectionViewCell {

    let autherImageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))
    let nameLabel = UILabel()
    let artistNameLabel = UILabel()
    
    fileprivate func stylizeUI() {
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
        artistNameLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        artistNameLabel.textColor = .lightGray
    }
    
    fileprivate func setupViews() {
        autherImageView.heightAnchor.constraint(equalTo: widthAnchor).isActive = true
        let stackView = UIStackView(arrangedSubviews: [autherImageView, nameLabel, artistNameLabel])
        stackView.axis = .vertical
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        stylizeUI()
        setupViews()
    }
}
