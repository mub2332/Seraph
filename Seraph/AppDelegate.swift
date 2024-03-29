//
//  AppDelegate.swift
//  Seraph
//
//  Created by Musa  Mahmud on 22/4/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var databaseController: DatabaseProtocol?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = DatabaseController()
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        
        let tabBarController = window?.rootViewController as! UITabBarController
        
        if userActivity.activityType == "com.example.seraph.SendSOS" {
            tabBarController.selectedIndex = 0
            let viewController = tabBarController.viewControllers?.first as! HomeVC
            viewController.sendSOS("")
            return true
        }else if userActivity.activityType == "com.example.seraph.MakeEmergencyCall" {
            tabBarController.selectedIndex = 0
            let viewController = tabBarController.viewControllers?.first as! HomeVC
            viewController.makeEmergencyCall("")
            return true
        } else if userActivity.activityType == "com.example.seraph.ImportContacts" {
            tabBarController.selectedIndex = 1
            let viewController = tabBarController.viewControllers![1].children.first as! ContactsListVC
            viewController.importContacts("")
            return true
        } else if userActivity.activityType == "com.example.seraph.AddContact" {
            tabBarController.selectedIndex = 1
            let viewController = tabBarController.viewControllers![1].children.first as! ContactsListVC
            viewController.addContact("")
            return true
        } else if userActivity.activityType == "com.example.seraph.SelectContact" {
            tabBarController.selectedIndex = 1
            return true
        } else if userActivity.activityType == "com.example.seraph.DeleteAllContacts" {
            tabBarController.selectedIndex = 1
            let viewController = tabBarController.viewControllers![1].children.first as! ContactsListVC
            viewController.deleteAllContacts("")
            return true
        } else if userActivity.activityType == "com.example.seraph.EditSOSMessage" {
            tabBarController.selectedIndex = 2
            return true
        } else if userActivity.activityType == "com.example.seraph.EditShortcuts" {
            tabBarController.selectedIndex = 3
            return true
        }
        
        return false
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

