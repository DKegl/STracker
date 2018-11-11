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
    @objc dynamic var airdate: String?
    @objc dynamic var summary: String?
    @objc dynamic var isSeen: Bool=false
    @objc dynamic var image:EpImage?
    
    @objc dynamic var show:RealmBookmakShow?
    //let show=LinkingObjects(fromType: RealmBookmakShow.self, property:"ParentShow")
    
    override class func primaryKey()->String{
        return "id"
    }
}

class EpImage: Object {
    @objc dynamic var medium: String?
    @objc dynamic var original: String?
}


class RealmBookmakShow: Object {
    @objc dynamic var showName: String?
    @objc dynamic var showStatus:String?
    @objc dynamic var showPremiered: String?
    @objc dynamic var showSummary: String?
    @objc dynamic var showId: Int=0
    @objc dynamic var isBookmark:Bool=false
    @objc dynamic var image:ShowImage?
    
    let realmEpisoden=List<RealmEpisodenInformation>()

    override class func primaryKey()->String{
        return "showId"
    }
}
class ShowImage: Object {
    @objc dynamic var medium: String?
    @objc dynamic var original: String?
}
