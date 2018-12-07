//
//  bookmarkCell.swift
//  SerienTracker
//
//  Created by Andre Frank on 17.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

typealias EpisodeProgress = (total: Int, progress: Int)

protocol bookmarkCellDelegate {
    func shareBtnTapped(name: String)
}

class bookmarkCell: UICollectionViewCell {
    @IBOutlet var showImage: CachedImageView!
    @IBOutlet var showFlag: UILabel!
    @IBOutlet var showName: UILabel!
    @IBOutlet var seasonsInfo: UILabel!
    @IBOutlet var episodeInfo: UILabel!
    @IBOutlet var episodesProgressView: UIProgressView!
    //
    @IBOutlet var separatorView: UIView!
    //Share variables
    var delegate: bookmarkCellDelegate?
    var name: String?
    //
    let extraTextPadding = 13
    
    private func setPositionOfFlagText(showFlag:String?){
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
        
        
    }
    
    func setBookmarkCell(show:RealmBookmarkShow){
        self.showName.text=show.showName
        //Should be set after showName is present
        //setPositionOfFlagText(showFlag: show.showStatus)
        self.showFlag.text=show.showStatus
        
        if let imageUrl=show.image?.original{
            showImage.loadImageFromUrl(imageUrl)
        }
        
        //Calculate Seasons and seen episodes
        typealias ShowCounters = (seasonCounter:Int,episodenCounter:Int)
        var prevSeason:Int=0
        let showCounter:ShowCounters = show.realmEpisoden.reduce((0,0)) { (tempResult, episode) in
            var result:ShowCounters=(0,0)
            
            if episode.isSeen{
                result.episodenCounter += 1
            }
            if episode.season != prevSeason{
                result.seasonCounter += 1
                prevSeason=episode.season
            }
            result.episodenCounter += tempResult.1
            result.seasonCounter += tempResult.0
            
            return result
        }
        
        
        self.episodeInfo.text = "\(showCounter.episodenCounter) episodes of \(show.realmEpisoden.count) seen"
        
        self.episodesProgressView.progress = Float(showCounter.episodenCounter)/Float(show.realmEpisoden.count)
        
        self.seasonsInfo.text="\(showCounter.seasonCounter) seasons"
        
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
    @IBAction func shareBtnPressed(_ sender: Any) {
        delegate?.shareBtnTapped(name: name!)
    }
}
