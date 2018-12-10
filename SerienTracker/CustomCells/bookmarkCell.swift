//
//  bookmarkCell.swift
//  SerienTracker
//
//  Created by Andre Frank on 17.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

typealias EpisodeProgress = (total: Int, progress: Int)

protocol bookmarkCellDelegate:class {
    func shareBtnTapped(name: String)
    var allowEpisodeSegue: Bool { get set }
    func deleteBookmark(showId:Int)
}

class bookmarkCell: UICollectionViewCell {
    @IBOutlet var showImage: CachedImageView!
    @IBOutlet var showFlag: UILabel!
    @IBOutlet var showName: UILabel!
    @IBOutlet var seasonsInfo: UILabel!
    @IBOutlet var episodeInfo: UILabel!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet var episodesProgressView: UIProgressView!
    //
    @IBOutlet var separatorView: UIView!
    // - Delete bookmark UI
    @IBOutlet var deleteBookmarkViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet var deleteBookmarkView: UIView!
    @IBOutlet var deleteBookmarkButton: UIButton!
    
    // Share variables
    weak var delegate: bookmarkCellDelegate?
    var name: String?
    //
    let extraTextPadding = 13
    
    private var _backingShowId:Int!
    
    // Currently not used - the show flag text will be left aligned in view
    private func setPositionOfFlagText(showFlag: String?) {
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
    
    func setBookmarkCell(show: RealmBookmarkShow) {
        self.showName.text = show.showName
        // Should be set after showName is present
        // setPositionOfFlagText(showFlag: show.showStatus)
        self.showFlag.text = show.showStatus
        
        //Used as a parameter in delete bookmark view
        _backingShowId=show.showId
        
        if let imageUrl = show.image?.original {
            self.showImage.loadImageFromUrl(imageUrl)
        }
        
        // Calculate Seasons and seen episodes
        typealias ShowCounters = (seasonCounter: Int, episodenCounter: Int)
        var prevSeason: Int = 0
        let showCounter: ShowCounters = show.realmEpisoden.reduce((0, 0)) { tempResult, episode in
            var result: ShowCounters = (0, 0)
            
            if episode.isSeen {
                result.episodenCounter += 1
            }
            if episode.season != prevSeason {
                result.seasonCounter += 1
                prevSeason = episode.season
            }
            result.episodenCounter += tempResult.1
            result.seasonCounter += tempResult.0
            
            return result
        }
        
        self.episodeInfo.text = "\(showCounter.episodenCounter) episodes of \(show.realmEpisoden.count) seen"
        
        self.episodesProgressView.progress = Float(showCounter.episodenCounter) / Float(show.realmEpisoden.count)
        
        self.seasonsInfo.text = "\(showCounter.seasonCounter) seasons"
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
        
        // Configure swipe view with default color style
        self.deleteBookmarkButton.backgroundColor = greyColor
        self.deleteBookmarkButton.setTitleColor(turquoiseColor, for: UIControl.State.normal)
        // By default this view will not be shown
        self.deleteBookmarkViewLeadingConstraint.constant = constraintToHide
        // install neccessary gestures to handle user interaction
        setupDeleteBookmarkSwipeGestures()
        setupDeleteBookmarkTap()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupViews()
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        self.delegate?.shareBtnTapped(name: self.name!)
    }
}

// MARK: - Show/Hide delete bookmark show View

extension bookmarkCell {
    func setupDeleteBookmarkTap() {
        self.deleteBookmarkButton.addTarget(self, action: #selector(self.deleteBookmarkTapped), for: UIControl.Event.touchUpInside)
    }
    
    @objc func deleteBookmarkTapped() {
        self.delegate?.deleteBookmark(showId: _backingShowId)
        self.swipeRightAction()
    }
    
    /// Setup the gestures for the deleteBookmark view
    ///
    /// - Parameter show:
    ///
    func setupDeleteBookmarkSwipeGestures() {
        var gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeLeftAction))
        gesture.direction = .left
        self.addGestureRecognizer(gesture)
        
        gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeRightAction))
        
        gesture.direction = .right
        self.deleteBookmarkView.addGestureRecognizer(gesture)
    }
    
    /// Animates the deleteBockmark view with a spring effect
    ///
    /// - Parameter show: TRUE --> view will be shown / FALSE-->view will be discarded
    ///
    ///   When view is visible no further cell action is possible
    func animateDeleteBookmarkView(show: Bool) {
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.deleteBookmarkViewLeadingConstraint.constant = show ? self.constraintToShow : self.constraintToHide
            self.layoutIfNeeded()
        }) { _ in
            self.delegate?.allowEpisodeSegue = !show
            self.shareButton.isUserInteractionEnabled = !show
        }
    }
    
    @objc func swipeRightAction() {
        self.animateDeleteBookmarkView(show: false)
    }
    
    @objc func swipeLeftAction() {
        self.animateDeleteBookmarkView(show: true)
    }
    
    var constraintToHide: CGFloat {
        return self.frame.width
    }
    
    var constraintToShow: CGFloat {
        return 0
    }
}
