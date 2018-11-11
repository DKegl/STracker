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
    
    var showInfo: ShowSearch?
    var showMainAPI = ShowMainApi()
    var showEpListAPI = ShowEpListApi()
    
    var realm: Realm {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.realm!
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
        showSummaryTextView.text = showInfo.show?.summary!.deleteHTMLTag(tag: "")
        showImageView.loadImageFromUrl((showInfo.show?.image!.original)!)
        statusLabel.text? = showInfo.show?.status ?? ""
        epButton.layer.cornerRadius = 20
    }
    
    @objc func bookmarkTapped() {
        print("tap tap")
        
        showMainAPI.getShowOverview(id: (showInfo?.show?.id)!) { [unowned self] show in
            self.showEpListAPI.getEpList(id: (self.showInfo?.show?.id)!, complition: { episoden in
                // Realm().object(ofType: Book.self, forPrimaryKey: prevBook.nextId)
                let showObject = self.realm.object(ofType: RealmBookmakShow.self, forPrimaryKey: show?.showId)
                if showObject?.isBookmark == true {
                    do {
                        try self.realm.write {
                            self.realm.delete((showObject?.realmEpisoden)!)
                            self.realm.delete(showObject!)
                            
                    } } catch let error {
                        print(error.localizedDescription)
                    }
                } else {
                    do {
                        try self.realm.write {
                            let realmShow = RealmBookmakShow()
                            realmShow.isBookmark = true
                            realmShow.showId = show?.showId ?? 0
                            realmShow.showName = show?.showName
                            realmShow.showStatus = show?.showStatus
                            realmShow.showPremiered = show?.showPremiered
                            realmShow.showSummary = show?.showSummary
                            
                            let image=ShowImage()
                            image.setValue(show?.image?.medium, forKey: "medium")
                            image.setValue(show?.image?.original, forKey: "original")
                            
                            realmShow.image=image
                            
                            var realmEpisoden = [RealmEpisodenInformation]()
                            for episode in episoden! {
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
                                let image=EpImage()
                                image.setValue(show?.image?.medium, forKey: "medium")
                                image.setValue(show?.image?.original, forKey: "original")
                                
                                realmEp.image=image
                                
                                realmEpisoden.append(realmEp)
                            }
                            realmShow.realmEpisoden.append(objectsIn: realmEpisoden)
                            self.realm.add(realmShow, update: true)
                        }
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
                
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let epListVC = segue.destination as! EpisodesListVC
        epListVC.showInfo = showInfo?.show?.id
        epListVC.showName = showInfo?.show?.name
    }
}
