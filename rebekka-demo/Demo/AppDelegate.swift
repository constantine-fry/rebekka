//
//  AppDelegate.swift
//  Demo
//
//  Created by Constantine Fry on 17/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import UIKit
import RebekkaTouch



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var session: Session!
    
    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        var configuration = SessionConfiguration()
        configuration.host = "ftp://speedtest.tele2.net"
        session = Session(configuration: configuration)
        session.list("/") {
            (resources, error) -> Void in
            print("List directory with result:\n\(resources), error: \(error)\n\n")
        }
        
        self.session.download("/200MB.zip") {
            (fileURL, error) -> Void in
            print("Download file with result:\n\(fileURL), error: \(error)\n\n")
            if let fileURL = fileURL {
                do {
                    try NSFileManager.defaultManager().removeItemAtURL(fileURL)
                } catch let error as NSError {
                    print("Error: \(error)")
                }
                
            }
        }
        /*
        if let URL = NSBundle.mainBundle().URLForResource("TestUpload", withExtension: "png") {
            let path = "/Users/fry/ftp/\(NSUUID().UUIDString).png"
            session.upload(URL, path: path) {
                (result, error) -> Void in
                print("Upload file with result:\n\(result), error: \(error)\n\n")
            }
        }
        
        let name = NSUUID().UUIDString
        session.createDirectory("/Users/fry/ftp/\(name)") {
            (result, error) -> Void in
            print("Create directory with result:\n\(result), error: \(error)")
        }
        */
        return true
    }


}

