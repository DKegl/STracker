//
//  mainCell.swift
//  SerienTracker
//
//  Created by Andre Frank on 11.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

class mainCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let insetRect=UIEdgeInsets(top:5, left: 5, bottom: 5, right: 5)
    
        contentView.frame.inset(by: insetRect)
        
       
        
    }

}
