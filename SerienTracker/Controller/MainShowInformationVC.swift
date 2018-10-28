//
//  MainShowInformationVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

class MainShowInformationVC: UIViewController {
    @IBOutlet var showLabel: UILabel!
    @IBOutlet var showImageView: CachedImageView!
    @IBOutlet var statusLabel: UILabel!
    
    @IBOutlet var showSummaryTextView: UITextView!
    
    var showInfo: ShowSearch?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupUI()
    }
    
    func setupUI() {
        guard let showInfo = showInfo else { fatalError("No show info available") }
        showLabel.text = showInfo.show?.name
        showSummaryTextView.text = showInfo.show?.summary.deleteHTMLTag(tag: "")
        showImageView.loadImageFromUrl((showInfo.show?.image.original)!)
        statusLabel.text? = showInfo.show?.status ?? ""
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let epListVC = segue.destination as! EpisodesListVC
        epListVC.showInfo = showInfo?.show?.id
        epListVC.showName = showInfo?.show?.name
    }
}
