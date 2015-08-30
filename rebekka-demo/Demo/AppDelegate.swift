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


}

