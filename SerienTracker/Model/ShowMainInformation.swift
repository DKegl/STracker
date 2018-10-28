//
//  ShowMainInformation.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 13.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Foundation

struct ShowMainInformation: Codable {
    var showName: String
    var showStatus: String
    var showPremiered: String
    var showSummary: String
    var showId: Int


enum CodingKeys: String, CodingKey {
    case showName = "name"
    case showStatus = "status"
    case showPremiered = "premiered"
    case showSummary = "summary"
    case showId = "id"
}
}
