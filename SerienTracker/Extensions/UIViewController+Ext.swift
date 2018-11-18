//
//  UIViewController+Extensions.swift
//  SerienTracker
//
//  Created by Andre Frank on 17.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

//MARK:- Set Title for UIViewController embedded in Tabbarcontroller
extension UIViewController{
    func setTabBarEmbeddedTitle(title:String){
        guard let tabController=self.tabBarController else {return}
        tabController.navigationItem.title=title
    }
}
