//
//  MainShowInformationVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit
import RealmSwift

class MainShowInformationVC: UIViewController {
    @IBOutlet var showLabel: UILabel!
    @IBOutlet var showImageView: CachedImageView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var epButton: UIButton!
    @IBOutlet var showSummaryTextView: UITextView!
    
    var showInfo: ShowSearch?
    var showMainAPI=ShowMainApi()
    var showEpListAPI=ShowEpListApi()
    
    var realm:Realm{
        let appDelegate=UIApplication.shared.delegate as! AppDelegate
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
       
        showMainAPI.getShowOverview(id: (showInfo?.show?.id)!) {[unowned self] (show) in
            self.showEpListAPI.getEpList(id: (self.showInfo?.show?.id)!, complition: { (episoden) in
                do{
                    try self.realm.write {
                        let realmShow=RealmBookmakShow()
                        realmShow.isBookmark=true
                        realmShow.showId=show?.showId ?? 0
                        realmShow.showName=show?.showName
                        
                        var realmEpisoden=[RealmEpisodenInformation]()
                        for episode in episoden!{
                            let realmEp=RealmEpisodenInformation()
                            realmEp.name=episode.name
                            realmEp.show=realmShow
                            realmEp.id=episode.id
                            realmEpisoden.append(realmEp)
                        }
                        realmShow.realmEpisoden.append(objectsIn: realmEpisoden)
                        self.realm.add(realmShow, update:true)
                    }
                }catch let error{
                    print(error.localizedDescription)
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
