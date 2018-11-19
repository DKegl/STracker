//
//  Constants.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 13.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Foundation
import UIKit

//MARK: JSON Urls
let URL_BASE = "http://api.tvmaze.com/"
let SHOW_URL = URL_BASE + "shows/"
let EPLIST_URL = "http://api.tvmaze.com/shows/1/episodes"
let SEARCH_URL = "http://api.tvmaze.com/search/shows?q="

//MARK: Json Completion handler
typealias ShowResponseCompletion = (ShowMainInformation?) -> Void
typealias EpListCompletion = ([ShowEpisodenInformation]?) -> Void
typealias SearchCompletion = ([ShowSearch]?) -> Void

// Colors

let turquoiseColor = UIColor(red:0.08, green:1.00, blue:0.93, alpha:1.0)
let blackColor = UIColor(red:0.13, green:0.13, blue:0.13, alpha:1.0)
let greyColor = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
let darkTurquoisColor = UIColor(red:0.05, green:0.45, blue:0.47, alpha:1.0)

//Schwarz: 212121
//Grau 323232
//Türkis 0d7377
//Grün 14ffec
