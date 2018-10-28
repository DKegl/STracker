//
//  previewViewController.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 28.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

class previewViewController: UIViewController {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var summaryLbl: UITextView!
    @IBOutlet weak var airdateLbl: UILabel!
    
    var episodenDetail: ShowEpisodenInformation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLbl.text = episodenDetail?.name
        summaryLbl.text = episodenDetail?.summary?.deleteHTMLTag(tag: "")
        airdateLbl.text = episodenDetail?.airdate
        // Do any additional setup after loading the view.
    }
    

   
}
