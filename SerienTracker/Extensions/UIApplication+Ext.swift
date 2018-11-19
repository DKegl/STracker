//
//  UIApplication+Ext.swift
//  SerienTracker
//
//  Created by Andre Frank on 19.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit


extension UIApplication{
    
    class func AppName()->String{
        return (Bundle.main.infoDictionary?[kCFBundleNameKey as String] as! String)
    }
    
}
