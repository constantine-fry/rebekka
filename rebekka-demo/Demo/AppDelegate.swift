//
//  AppDelegate.swift
//  Demo
//
//  Created by Constantine Fry on 17/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import UIKit
import RebekkaTouch

var _session: Session!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        var configuration = SessionConfiguration()
        configuration.host = "ftp://ftp.mozilla.org:21"
        _session = Session(configuration: configuration)
        _session.list("/") {
            (resources, error) -> Void in
            println("List directory with result:\n\(resources), error: \(error)\n\n")
        }
        /*
        _session.download("/Users/fry/ftp/test.png") {
            (fileURL, error) -> Void in
            println("Download file with result:\n\(fileURL), error: \(error)\n\n")
            if fileURL != nil {
                NSFileManager.defaultManager().removeItemAtURL(fileURL!, error: nil)
            }
        }
        
        if let URL = NSBundle.mainBundle().URLForResource("testUpload", withExtension: "png") {
            let path = "/Users/fry/ftp/\(NSUUID().UUIDString).png"
            _session.upload(URL, path: path) {
                (result, error) -> Void in
                println("Upload file with result:\n\(result), error: \(error)\n\n")
            }
        }
        
        let name = NSUUID().UUIDString
        _session.createDirectory("/Users/fry/ftp/\(name)") {
            (result, error) -> Void in
            println("Create directory with result:\n\(result), error: \(error)")
        }
        */
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

