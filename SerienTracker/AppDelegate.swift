//
//  AppDelegate.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 13.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import RealmSwift
import UIKit

extension UIApplicationDelegate {
    func delayLaunchScreen(time: TimeInterval = 0) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: time))
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var realm: Realm?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // MARK: - Navbar Setup
        setupNavigationBar()
        // MARK: - Tabbar Setup
        setupTabBar()
        // init Realm database use different task but in main-thread!!
        setupRealm()
        // Delay return in main task
        delayLaunchScreen(time: 2)
        // no delay use:
        // self.delayLaunchScreen()
        return true
    }
}

// MARK: - Setup methods of the app

extension AppDelegate {
    func setupNavigationBar() {
        UINavigationBar.appearance().barTintColor = blackColor
        UINavigationBar.appearance().tintColor = turquoiseColor
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor(red: 0.08, green: 1.00, blue: 0.93, alpha: 1.0)]
        UINavigationBar.appearance().isTranslucent = false
    }
    
    func setupTabBar() {
        UITabBar.appearance().tintColor = turquoiseColor
        // UITabBar.appearance().bartint
    }
    
    func setupRealm() {
        let concurrentQueue = DispatchQueue(label: "initRealmQueue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent)
        concurrentQueue.async { [weak self] in
            
            DispatchQueue.main.async { [weak self] in
                do {
                    let realm = try Realm()
                    self?.realm = realm
                    print(Realm.Configuration.defaultConfiguration.fileURL!)
                    
                } catch let error {
                    print(Realm.Configuration.defaultConfiguration.fileURL!)
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
