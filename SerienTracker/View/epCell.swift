//
//  epCell.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 01.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

class epCell: UITableViewCell {
    @IBOutlet var epImage: CachedImageView?
    @IBOutlet var noLbl: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var dateLbl: UILabel!
    
    @IBOutlet var cellImage: UIImageView!
    
    func setEp(episode: ShowEpisodenInformation) {
        cellImage.layer.cornerRadius = 20
        cellImage.layer.borderWidth = 2
        cellImage.layer.borderColor = turquoiseColor.cgColor
        
        noLbl.text = "\(episode.number ?? 00)."
        titleLbl.text = episode.name
        dateLbl.text = episode.airdate
        
        if (episode.image?.original) == nil {
            return
        } else {
            epImage!.loadImageFromUrl((episode.image?.original)!)
        }
    }
}
