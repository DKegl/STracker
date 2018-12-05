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
    
    @IBOutlet var containerView: UIView!
    
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    private var _backingImageWidthConstraintConst:CGFloat!
    
    override func awakeFromNib() {
        //Save the value of the imageView's width constraint constant
        _backingImageWidthConstraintConst=imageWidthConstraint.constant
    }
    
    func setEp(episode: ShowEpisodenInformation) {
        //Round corner for the container view
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 2
        containerView.layer.borderColor = turquoiseColor.cgColor
        containerView.backgroundColor = greyColor
        noLbl.text = "\(episode.number ?? 00)."
        titleLbl.text = episode.name
        dateLbl.text = episode.airdate
        
        //Keep font size
        titleLbl.adjustsFontSizeToFitWidth=true
        
        //Change position of the subview elements due to the availability of the image
        if (episode.image?.original) == nil {
            imageWidthConstraint.constant=0
            return
        } else {
            imageWidthConstraint.constant = _backingImageWidthConstraintConst
            epImage!.loadImageFromUrl((episode.image?.original)!)
        }
    }
}
