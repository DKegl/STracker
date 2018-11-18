//
//  String+Ext.swift
//  SerienTracker
//
//  Created by Andre Frank on 18.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

extension String {
    func addPaddingCharacter(char: Character, count: Int) -> String {
        let padding = String(repeating: char, count: count)
        return padding + self
    }

    func width(usedFont: UIFont, boundWidth: CGFloat) -> CGFloat {
        // Get font attributes from string
        let attr = [NSAttributedString.Key.font: usedFont]
        // Get rect
        let caluclatedRect = self.boundingRect(with: CGSize(width: boundWidth, height: .greatestFiniteMagnitude), options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading], attributes: attr, context: nil)
        return caluclatedRect.width
    }
}
