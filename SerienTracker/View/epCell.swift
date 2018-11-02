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
    

    
    func setEp(episode: ShowEpisodenInformation) {
        noLbl.text = "\(episode.number ?? 00)."
        titleLbl.text = episode.name
        dateLbl.text = episode.airdate
        // showImageView.loadImageFromUrl((showInfo.show?.image.original)! ?? "http://static.tvmaze.com/uploads/images/original_untouched/156/392357.jpg"
        if ((episode.image?.original) == nil) {
        dateLbl.text = "nil"
        }else{
            epImage!.loadImageFromUrl((episode.image?.original)!)
        }
        }
    
        
        
    }



