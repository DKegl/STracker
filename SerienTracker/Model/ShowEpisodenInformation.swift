//
//  ShowEpisodenInformation.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 18.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

struct ShowEpisodenInformation: Codable {
    let id: Int
    let url, name: String
    let season, number: Int?
    let airdate, airtime, airstamp: String?
    let runtime: Int?
    let summary: String?
    var seen: Bool? = false
    let image: epImage?
}

struct epImage: Codable {
    let medium, original: String
}
