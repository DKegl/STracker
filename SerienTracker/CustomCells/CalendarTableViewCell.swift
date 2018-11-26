//
//  CalendarTableViewCell.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 26.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit
import RealmSwift
class CalendarTableViewCell: UITableViewCell {
    @IBOutlet var seasonLbl: UILabel!
    @IBOutlet var episodenNo: UILabel!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var showLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    //        cell.textLabel?.text = showAtDate[indexPath.row].name
    //        cell.detailTextLabel?.text = showAtDate[indexPath.row].show?.showName
    func setShowAtDay(show: RealmEpisodenInformation) {
        seasonLbl.text = "Season: \(show.season)"
        episodenNo.text = "Episode: \(show.number)"
        titleLbl.text = show.name
        showLbl.text = show.show?.showName
    }
}
