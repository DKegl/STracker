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
    
    lazy var showStore: ShowStoreManager = {
        ShowStoreManager.shared
    }()
    
    // 19.11.2018 Refresh bookmark 'star'
    var bookmark: Bool = false {
        didSet {
            bookmark == true ? (bookmarkImg.alpha = 1) : (bookmarkImg.alpha = 0)
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
        
        // refresh bookmark 'star'
        bookmark = showStore.isShowBookmark(id: showInfo.show!.id)
        // Show status
        statusLabel.text? = showInfo.show?.status ?? ""
        epButton.layer.cornerRadius = 20
    }
    
    func loadAndSaveShow(id:Int){
        // Configure response message
        let userConfirmation = UserActionConfirmView(title: "", message: "", imageName: "45-Bookmark.json")
        
        // 3.Selected show isn't boookmarked so load show information with episodes from endpoint
        // and save the show in the database within the sequentilly nested completion blocks
        showMainAPI.getShowOverview(id: id) { [unowned self] show in
            if let show = show {
                self.showEpListAPI.getEpList(id: id, complition: { [unowned self] episodes in
                    _ = self.showStore.saveAsBookmarkShow(show: show, episodes: episodes)
                    
                    // >>>>>>>>>>>>>>>>>19.11.2018 bug fix
                    userConfirmation.show(animated: true, animation: BookMarkAnimation.Add)
                    self.bookmark = true
                    // <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
                }) // end of inner block
            } // end of if let show
        } // end of outer block
    }
    
    @objc func bookmarkTapped() {
        // 1. Check if selected show is already in database
        // assuming the bookmark flag is set
        if let id = showInfo?.show?.id, showStore.isShowBookmark(id: id) {
            _ = showStore.deleteBookmarkShow(id: id)
            // User response message
            // Configure response message
            let userConfirmation = UserActionConfirmView(title: "", message: "", imageName: "45-Bookmark.json")
            userConfirmation.show(animated: true, animation: BookMarkAnimation.Remove)
            bookmark = false
        } else {
            guard let id=showInfo?.show?.id else {return}
            loadAndSaveShow(id: id)
        } // else
    } // end of method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let epListVC = segue.destination as! EpisodesListVC
        epListVC.showInfo = showInfo?.show?.id
        epListVC.showName = showInfo?.show?.name
    }
}
