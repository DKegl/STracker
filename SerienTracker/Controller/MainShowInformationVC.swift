//
//  MainShowInformationVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import RealmSwift
import UIKit

class MainShowInformationVC: UIViewController {
    @IBOutlet var showLabel: UILabel!
    @IBOutlet var showImageView: CachedImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var epButton: UIButton!
    @IBOutlet var showSummaryTextView: UITextView!
    @IBOutlet var bookmarkImg: UIImageView!
    
    var showInfo: ShowSearch?
    var showMainAPI = ShowMainApi()
    var showEpListAPI = ShowEpListApi()
    
    var operationShow: ShowMainInformation?
    var operationEpisodes: [ShowEpisodenInformation]?
    
    lazy var realm: Realm = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.realm!
    }()
    
    func realmShowFilterWith(id: Int) -> Results<RealmBookmarkShow> {
        return realm.objects(RealmBookmarkShow.self).filter("showId==\(id)")
    }
    
    // 19.11.2018 Refresh bookmark 'star'
    var bookmark: Bool = false {
        didSet {
            bookmark == true ? (bookmarkImg.alpha = 1) : (bookmarkImg.alpha = 0)
        }
    }
    
    func checkIfBookmarked(id: Int) -> Bool {
        let obj = realm.objects(RealmBookmarkShow.self).filter("showId==\(id)").first
        if obj == nil {
            return false
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
        navigationItem.title = showInfo?.show?.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(bookmarkTapped))
    }
    
    func setupUI() {
        guard let showInfo = showInfo else { fatalError("No show info available") }
        showLabel.text = showInfo.show?.name
        if let summary = showInfo.show?.summary {
            showSummaryTextView.text = summary.deleteHTMLTag(tag: "")
        } else {
            showSummaryTextView.text = "No show information available"
        }
        
        if let imageUrl = showInfo.show?.image?.original {
            showImageView.loadImageFromUrl(imageUrl)
        } else if let imageUrl = showInfo.show?.image?.medium {
            showImageView.loadImageFromUrl(imageUrl)
        } else {
            print("No image available")
        }
        
        // 19.11.2018 - Smarter solution
        bookmark = checkIfBookmarked(id: showInfo.show!.id) == true ? true : false
        
        statusLabel.text? = showInfo.show?.status ?? ""
        epButton.layer.cornerRadius = 20
    }
    
    @objc func bookmarkTapped() {
        // Configure response message
        let userConfirmation = UserActionConfirmView(title: "", message: "", imageName: "45-Bookmark.json")
        
        // 1. Check if selected show is already in database
        // assuming the bookmark flag is set
        if let id = showInfo?.show?.id,
            self.realmShowFilterWith(id: id).count > 0 {
            _ = deleteBookmarkShow(realmShow: realmShowFilterWith(id: id)[0])
            
            // >>>>>>>>>19.11.2018 Bug fix
            userConfirmation.show(animated: true, animation: BookMarkAnimation.Remove)
            bookmark = false
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<
            
        } else {
            // 3.Selected show isn't boookmarked so load show information with episodes from endpoint
            // and save the show in the database within the sequentilly nested completion blocks
            guard let id = showInfo?.show?.id else { return }
            showMainAPI.getShowOverview(id: id) { [unowned self] show in
                if let show = show {
                    self.showEpListAPI.getEpList(id: id, complition: { [unowned self] episodes in
                        _ = self.saveAsBookmarkShow(show: show, episodes: episodes)
                        // >>>>>>>>>>>>>>>>>19.11.2018 bug fix
                        userConfirmation.show(animated: true, animation: BookMarkAnimation.Add)
                        self.bookmark = true
                        // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                    }) // end of inner block
                } // end of if let show
            } // end of outer block
        } // else
    } // end of method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let epListVC = segue.destination as! EpisodesListVC
        epListVC.showInfo = showInfo?.show?.id
        epListVC.showName = showInfo?.show?.name
    }
}

extension MainShowInformationVC {
    func saveAsBookmarkShow(show: ShowMainInformation, episodes: [ShowEpisodenInformation]?) -> Bool {
        do {
            try realm.write {
                let realmShow = RealmBookmarkShow()
                realmShow.isBookmark = true
                realmShow.showId = show.showId
                realmShow.showName = show.showName
                realmShow.showStatus = show.showStatus
                realmShow.showPremiered = show.showPremiered
                realmShow.showSummary = show.showSummary
                
                let image = RealmShowImage()
                image.medium = show.image?.medium
                image.original = show.image?.original
                image.showId = show.showId
                realmShow.setValue(image, forKey: "image")
                
                var realmEpisoden = [RealmEpisodenInformation]()
                if let episodes = episodes {
                    realmEpisoden = episodes.map({ (episode) -> RealmEpisodenInformation in
                        let realmEp = RealmEpisodenInformation()
                        realmEp.name = episode.name
                        realmEp.show = realmShow
                        realmEp.id = episode.id
                        realmEp.url = episode.url
                        realmEp.season = episode.season ?? 0
                        realmEp.number = episode.number ?? 0
                        realmEp.airdate = episode.airdate
                        realmEp.summary = episode.summary
                        realmEp.isSeen = false
                        
                        let image = RealmEpImage()
                        image.medium = episode.image?.medium
                        image.original = episode.image?.original
                        image.episodeId = realmEp.id
                        image.showId = show.showId
                        realmEp.setValue(image, forKey: "image")
                        return realmEp
                    })
                    realmShow.realmEpisoden.append(objectsIn: realmEpisoden)
                }
                
                self.realm.add(realmShow, update: true)
            }
        } catch let error {
            print(error.localizedDescription)
            return false
        }
        return true
    }
    
    func deleteBookmarkShow(realmShow: RealmBookmarkShow) -> Bool {
        let showImageObject = realm.object(ofType: RealmShowImage.self, forPrimaryKey: realmShow.showId)
        do {
            try realm.write {
                self.realm.delete(showImageObject!)
                let episodeShowImages = self.realm.objects(RealmEpImage.self).filter("showId==\(realmShow.showId)")
                if episodeShowImages.count > 0 {
                    self.realm.delete(episodeShowImages)
                }
                
                self.realm.delete(realmShow.realmEpisoden)
                self.realm.delete(realmShow)
                
        } } catch let error {
            print(error.localizedDescription)
            return false
        }
        return true
    }
}
