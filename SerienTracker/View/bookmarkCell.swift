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
    
    //
    @IBOutlet var separatorView: UIView!
    
    //
    let extraTextPadding = 13
    
    func setBookmarkCell(showImage: UIImage?, showFlag: String?, showName: String?, episodesInfo: String?, seen: EpisodeProgress, seasonInfo: String?) {
        self.showImage.image = showImage
        
        self.showName.text = showName
        // Calculate offset of showflag dynically
        // 1.Get actual width of content text
        let showNameTextWidth = self.showName.intrinsicContentSize.width
        var paddingTextLength: CGFloat = 0
        var flagText = showFlag
        // 2. Add padding character as long as showflag.text is shorter + extraPadding character
        repeat {
            flagText = flagText?.addPaddingCharacter(char: " ", count: self.extraTextPadding)
            self.showFlag.text = flagText
            paddingTextLength = (flagText?.width(usedFont: self.showFlag.font, boundWidth: self.showFlag.intrinsicContentSize.width))!
        } while Int(showNameTextWidth) > Int(paddingTextLength)
        
        self.episodeInfo.text = episodesInfo
        self.seasonsInfo.text = seasonInfo
        self.episodesProgressView.progress = Float(Float(seen.progress) / Float(seen.total))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.separatorView.layer.borderWidth = 0.5
        self.separatorView.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupViews() {
        self.showFlag.textColor = .lightGray
        self.showName.textColor = turquoiseColor
        self.episodeInfo.textColor = .lightGray
        self.seasonsInfo.textColor = .lightGray
        self.episodesProgressView.tintColor = turquoiseColor
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
}
