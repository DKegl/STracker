//
//  mainCell.swift
//  SerienTracker
//
//  Created by Andre Frank on 11.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

class mainCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var showTitleLabel: UILabel!
    
    func setMainCell(cellInfo:String){
        //Set rounded corners to containerView
        containerView.layer.borderColor = turquoiseColor.cgColor
        containerView.layer.cornerRadius = 20
        containerView.layer.borderWidth = 2
        
        showTitleLabel.text=cellInfo
    }
   

}
