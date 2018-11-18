//
//  bookmarkCell.swift
//  SerienTracker
//
//  Created by Andre Frank on 17.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

typealias EpisodeProgress = (total: Int, progress: Int)

class bookmarkCell: UICollectionViewCell {
    @IBOutlet var showImage: UIImageView!
    @IBOutlet var showFlag: UILabel!
    @IBOutlet var showName: UILabel!
    @IBOutlet var seasonsInfo: UILabel!
    @IBOutlet var episodeInfo: UILabel!
    @IBOutlet var episodesProgressView: UIProgressView!
    
    func setBookmarkCell(showImage: UIImage?, showFlag: String?, showName: String?, episodesInfo: String?, seen: EpisodeProgress, seasonInfo: String?) {
        self.showImage.image = showImage
        self.showFlag.text = showFlag
        self.showName.text = showName
        self.episodeInfo.text = episodesInfo
        self.seasonsInfo.text = seasonInfo
        self.episodesProgressView.progress = Float(Float(seen.progress) / Float(seen.total))
    }
    
    private func setupViews() {
        self.showFlag.textColor = .lightGray
        self.showName.textColor = turquoiseColor
        self.episodeInfo.textColor = .lightGray
        self.seasonsInfo.textColor = .lightGray
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
