//
//  AppDelegate.swift
//  Pizza
//
//  Created by Alexander Kosse on 14/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

extension UIColor {
    
    static func RGB(red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: 1)
    }
    static func ARGB(alpha: Int, red: Int, green: Int, blue: Int) -> UIColor {
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: CGFloat(alpha)/255)
    }
    static func HEX(_ rgb: Int64) -> UIColor {
        if rgb > 0xFFFFFF {
            return ARGB(alpha:Int(rgb >> 24), red: Int(rgb >> 16) & 0xFF, green: Int(rgb >> 8) & 0xFF, blue: Int(rgb & 0xFF))
        }
        return RGB(red: Int(rgb >> 16) & 0xFF, green: Int(rgb >> 8) & 0xFF, blue: Int(rgb & 0xFF))
    }
    static func DarkCoral() -> UIColor {
        return HEX(0xd86a43)
    }
    static func LightCoral() -> UIColor {
        return HEX(0xf88a63)
    }
    static func AlphaCoral() -> UIColor {
        return HEX(0xb0d86a43)
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        let mainTintColor = UIColor.DarkCoral()
        let font = UIFont.systemFont(ofSize: 17, weight: .light)
        UINavigationBar.appearance().barTintColor = mainTintColor
        UINavigationBar.appearance().tintColor = .white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : UIColor.white, NSAttributedStringKey.font : font]
        UINavigationBar.appearance().shadowImage = UIImage()
        //UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().backgroundColor = mainTintColor
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .white
        UITabBar.appearance().barTintColor = .white
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().backgroundColor = .white
        if #available(iOS 11.0, *) {
            UIRefreshControl.appearance(whenContainedInInstancesOf: [UINavigationBar.self]).tintColor = .white
        }
        if #available(iOS 10, *) {
            UITabBarItem.appearance().badgeColor = UIColor.LightCoral()
            UITabBarItem.appearance()
        }
        window?.tintColor = mainTintColor
        UIApplication.shared.statusBarStyle = .lightContent
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

