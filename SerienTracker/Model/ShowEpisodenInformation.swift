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
        let medium, original: String
    }    
}

