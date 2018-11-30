//
//  ShowEpisodenInformation.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 18.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

struct ShowEpisodenInformation: Codable {
    let id: Int
    let url, name: String?
    let season, number: Int?
    let airdate: String?
    let summary: String?
    let image: epImage?
    //This property isn't part of the JSON Decoder
    var seen:Bool?
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case url = "url"
        case name = "name"
        case airdate = "airdate"
        case season = "season"
        case number = "number"
        case summary = "summary"
        case image = "image"
       //This property isn't part of the JSON Decoder
        case seen = "seen"
    }
    
    struct epImage: Codable {
        let medium, original: String?
        
        init(medium:String?,original:String?) {
            self.medium=medium
            self.original=original
        }
        
        init(image:epImage) {
            self.init(medium: image.medium, original: image.original)
        }
    }
    
    init(id:Int,url:String?,name:String?,airdate:String?,season:Int?,number:Int?,image:epImage?,seen:Bool,summary:String?) {
        self.id=id
        self.url=url
        self.name=name
        self.airdate=airdate
        self.season=season
        self.number=number
        self.seen=seen
        if let image=image{
          self.image=epImage(medium: image.medium, original:image.original)
        }else{
            self.image=nil
        }
        self.summary=summary
    }
    
   
    
}

