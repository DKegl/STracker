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
        
        if checkIfBookmarked(id: showInfo.show!.id) == true {
            bookmarkImg.isHidden = false
        } else {
            bookmarkImg.isHidden = true
        }
        
        statusLabel.text? = showInfo.show?.status ?? ""
        epButton.layer.cornerRadius = 20
    }
    
    @objc func bookmarkTapped() {
        print("tap tap")
        
        // Configure response message
        let userConfirmation = UserActionConfirmView(title: "", message: "", imageName: "45-Bookmark.json")
        
        // 1. Check if selected show is already in database
        // assuming the bookmark flag is set
        if let id = showInfo?.show?.id,
            self.realmShowFilterWith(id: id).count > 0 {
            // 2. Delete the show with all episodes & images
            userConfirmation.customTitle = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
            userConfirmation.customMessage = "Bookmark removed from show"
            
            _ = deleteBookmarkShow(realmShow: realmShowFilterWith(id: id)[0])
            // >>>>>>>>>19.11.2018 Bug fix
            userConfirmation.show(animated: true, animation: BookMarkAnimation.Remove)
            // <<<<<<<<<<<<<<<<<<<<<<<<<<<<
            
        } else {
            // 3.Selected show isn't boookmarked so load show information with episodes from endpoint
            // and save the show in the database within the sequentilly nested completion blocks
            guard let id = showInfo?.show?.id else { return }
            showMainAPI.getShowOverview(id: id) { [unowned self] show in
                if let show = show {
                    self.showEpListAPI.getEpList(id: id, complition: { [unowned self] episodes in
                        userConfirmation.customTitle = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
                        userConfirmation.customMessage = "\(show.showName) bookmarked"
                        
                        _ = self.saveAsBookmarkShow(show: show, episodes: episodes)
                        // >>>>>>>>>>>>>>>>>19.11.2018 bug fix
                        userConfirmation.show(animated: true, animation: BookMarkAnimation.Add)
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

// MARK: - Using NSOperation queue to save/delete bookmarks

extension MainShowInformationVC {
    func excuteOperationsWithShowInformation(id: Int) {
        let queue = OperationQueue()
        
        // Create Operations in sequence for nested asyn methods
        let operation1 = ShowOperation(id: id)
        let operation2 = EpisodesOperation(id: id)
        // Output operation
        let combinedOperation = BlockOperation { [unowned operation1, operation2] in
            let show = operation1.outData as? ShowMainInformation
            let episodes = operation2.outData as? [ShowEpisodenInformation]
            // Output must be executed in main thread
            OperationQueue.main.addOperation {
                if let showObject = self.realm.object(ofType: RealmBookmarkShow.self, forPrimaryKey: show?.showId) {
                    _ = self.deleteBookmarkShow(realmShow: showObject)
                } else {
                    _ = self.saveAsBookmarkShow(show: show!, episodes: episodes!)
                }
            }
        }
        
        // Dependencies between them
        operation2.addDependency(operation1)
        combinedOperation.addDependency(operation2)
        // Execute all operations
        queue.addOperations([operation1, operation2, combinedOperation], waitUntilFinished: false)
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
