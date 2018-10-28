//
//  String+Extension.swift
//  SerienTracker
//
//  Created by Andre Frank on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Foundation

extension String {
    func deleteHTMLTag(tag:String) -> String {
        return self.replacingOccurrences(of: "(?i)</?\(tag)\\b[^<]*>", with: "", options: .regularExpression, range: nil)
    }
    
    func deleteHTMLTags(tags:[String]) -> String {
        var mutableString = self
        for tag in tags {
            mutableString = mutableString.deleteHTMLTag(tag: tag)
        }
        return mutableString
    }
}
