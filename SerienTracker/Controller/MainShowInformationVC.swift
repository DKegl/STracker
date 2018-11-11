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
        if let summary=showInfo.show?.summary{
            showSummaryTextView.text = summary.deleteHTMLTag(tag: "")
        }else{
             showSummaryTextView.text = "No show information available"
        }

        if let imageUrl=showInfo.show?.image?.original{
             showImageView.loadImageFromUrl(imageUrl)
        }else if let imageUrl=showInfo.show?.image?.medium{
            showImageView.loadImageFromUrl(imageUrl)
        }else{
            print("No image available")
        }
       
        statusLabel.text? = showInfo.show?.status ?? ""
        epButton.layer.cornerRadius = 20
    }
    
    @objc func bookmarkTapped() {
        print("tap tap")
        
        showMainAPI.getShowOverview(id: (showInfo?.show?.id)!) { [weak self] show in
            guard let show=show else {
                fatalError("No show found")
            }
            
            self?.showEpListAPI.getEpList(id: (self?.showInfo?.show?.id)!, complition: { [weak self] episoden in
                // Realm().object(ofType: Book.self, forPrimaryKey: prevBook.nextId)
                let showObject = self?.realm.object(ofType: RealmBookmakShow.self, forPrimaryKey: show.showId)
               
                if showObject?.isBookmark == true {
                    do {
                        try self?.realm.write {
                            self?.realm.delete((showObject?.realmEpisoden)!)
                            self?.realm.delete(showObject!)
                            
                    } } catch let error {
                        print(error.localizedDescription)
                    }
                } else {
                    do {
                        try self?.realm.write {
                            let realmShow = RealmBookmakShow()
                            realmShow.isBookmark = true
                            realmShow.showId = show.showId
                            realmShow.showName = show.showName
                            realmShow.showStatus = show.showStatus
                            realmShow.showPremiered = show.showPremiered
                            realmShow.showSummary = show.showSummary
                            
                            
                            let image=ShowImage()
                            image.medium=show.image?.medium
                            image.original=show.image?.original
                            realmShow.setValue(image, forKey: "image")
                    
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
                                image.medium=episode.image?.medium
                                image.original=episode.image?.original
                                realmEp.image=image
                                
                                realmEpisoden.append(realmEp)
                            }
                            realmShow.realmEpisoden.append(objectsIn: realmEpisoden)
                            self?.realm.add(realmShow, update: true)
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
