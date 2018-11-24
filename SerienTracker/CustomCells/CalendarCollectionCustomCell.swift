//
//  CalendarCollectionCustomCell.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 24.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCollectionCustomCell: JTAppleCell {

    @IBOutlet weak var indicatorView: UIView!
    @IBOutlet weak var dayLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        indicatorView.layer.cornerRadius = 3
        
    }
    
    
}
