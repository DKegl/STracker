//
//  bookmarkCell.swift
//  SerienTracker
//
//  Created by Andre Frank on 17.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

typealias EpisodeProgress = (total: Int, progress: Int)

extension String{
    func addPaddingCharacter(char:Character,count:Int)->String{
       let padding=String(repeating: char, count: count)
       return padding+self
    }
}

class bookmarkCell: UICollectionViewCell {
    @IBOutlet var showImage: UIImageView!
    @IBOutlet var showFlag: UILabel!
    @IBOutlet var showName: UILabel!
    @IBOutlet var seasonsInfo: UILabel!
    @IBOutlet var episodeInfo: UILabel!
    @IBOutlet var episodesProgressView: UIProgressView!
    
    //
    @IBOutlet weak var separatorView: UIView!
    
    //
    let etraTextPadding=13
    
    func setBookmarkCell(showImage: UIImage?, showFlag: String?, showName: String?, episodesInfo: String?, seen: EpisodeProgress, seasonInfo: String?) {
        self.showImage.image = showImage
        
        self.showName.text = showName
        self.showFlag.text = showFlag?.addPaddingCharacter(char: " ", count: (showName?.count)!+etraTextPadding)
        
        
        
        self.episodeInfo.text = episodesInfo
        self.seasonsInfo.text = seasonInfo
        self.episodesProgressView.progress = Float(Float(seen.progress) / Float(seen.total))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        separatorView.layer.borderWidth=0.5
        separatorView.layer.borderColor = UIColor.lightGray.cgColor
        
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
        setupViews()
    }
}
