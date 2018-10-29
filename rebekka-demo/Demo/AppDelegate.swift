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
    
    private func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
            
        var configuration = SessionConfiguration()
        configuration.host = "ftp://speedtest.tele2.net"
        configuration.passive = true
        
        self.session = Session(configuration: configuration)
        
        testList()
        testDownload()
        testUpload()
        testCreate()
        
        return true
    }
    
    func testList() {
        self.session.list("/") {
            (resources, error) -> Void in
            print("List directory with result:\n\(String(describing: resources)), error: \(String(describing: error))\n\n")
        }
    }
    
    func testUpload() {
        if let URL = Bundle.main.url(forResource: "TestUpload", withExtension: "png") {
            let path = "/upload/\(UUID().uuidString).png"
            self.session.upload(URL, path: path, progressHandler: { (progress) in
                print("Progresso: \(progress)")
            }, completionHandler: { (complete, error) in
                print("Complete")
            })
        }
    }
    
    func testDownload() {
        
        self.session.download("/5MB.zip", progressHandler: { (progress) in
            print("Progress: \(progress)");
        }) { (fileURL, error) in
            if let fileURL = fileURL {
                do {
                    try FileManager.default.removeItem(at: fileURL)
                } catch let error as NSError {
                    print("Error: \(error)")
                }
                
            }
        }
        
    }
    
    func testCreate() {
        let name = UUID().uuidString
        self.session.createDirectory("/upload/\(name)") {
            (result, error) -> Void in
            print("Create directory with result:\n\(result), error: \(String(describing: error))")
        }
    }
    
    
}

