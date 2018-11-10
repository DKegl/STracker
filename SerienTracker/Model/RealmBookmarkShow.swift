//
//  RealmBookmarkShow.swift
//  SerienTracker
//
//  Created by Andre Frank on 10.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Foundation
import RealmSwift

class RealmEpisodenInformation: Object {
    @objc dynamic var id: Int=0
    @objc dynamic var url, name: String?
    @objc dynamic var season:Int=0, number:Int=0
    @objc dynamic var airdate, airtime, airstamp: String?
    @objc dynamic var runtime: Int=0
    @objc dynamic var summary: String?
    @objc dynamic var seen: Bool=false
    @objc dynamic var image:RealmImage?
    
    @objc dynamic var show:RealmBookmakShow?
}

class RealmImage: Object {
    @objc dynamic var medium, original: String?
}


class RealmBookmakShow: Object {
    @objc dynamic var showName: String?
    @objc dynamic var showStatus:String?
    @objc dynamic var showPremiered: String?
    @objc dynamic var showSummary: String?
    @objc dynamic var showId: Int=0
    
    let episoden=List<RealmEpisodenInformation>()
    
    
}
