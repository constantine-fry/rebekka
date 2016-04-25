//
//  Session.swift
//  Rebekka
//
//  Created by Constantine Fry on 17/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

public typealias ResourceResultCompletionHandler = ([ResourceItem]?, NSError?) -> Void
public typealias FileURLResultCompletionHandler = (NSURL?, NSError?) -> Void
public typealias BooleanResultCompletionHandler = (Bool, NSError?) -> Void


/** The FTP session. */
public class Session {
    /** The serial private operation queue. */
    private let operationQueue: NSOperationQueue
    
    /** The queue for completion handlers. */
    private let completionHandlerQueue: NSOperationQueue
    
    /** The serial queue for streams in operations. */
    private let streamQueue: dispatch_queue_t
    
    /** The configuration of the session. */
    private let configuration: SessionConfiguration
    
    public init(configuration: SessionConfiguration,
        completionHandlerQueue: NSOperationQueue = NSOperationQueue.mainQueue()) {
            operationQueue = NSOperationQueue()
            operationQueue.maxConcurrentOperationCount = 1
            operationQueue.name = "net.ftp.rebekka.operations.queue"
            streamQueue = dispatch_queue_create("net.ftp.rebekka.cfstream.queue", nil)
            self.completionHandlerQueue = completionHandlerQueue
            self.configuration = configuration
    }
    
    /** Returns content of directory at path. */
    public func list(path: String, completionHandler: ResourceResultCompletionHandler) {
        let operation = ResourceListOperation(configuration: configuration, queue: streamQueue)
        operation.completionBlock = {
            [weak operation] in
            if let strongOperation = operation {
                self.completionHandlerQueue.addOperationWithBlock {
                    completionHandler(strongOperation.resources, strongOperation.error)
                }
            }
        }
        operation.path = path
        if !path.hasSuffix("/") {
            operation.path = path + "/"
        }
        operationQueue.addOperation(operation)
    }
    
    /** Creates new directory at path. */
    public func createDirectory(path: String, completionHandler: BooleanResultCompletionHandler) {
        let operation = DirectoryCreationOperation(configuration: configuration, queue: streamQueue)
        operation.completionBlock = {
            [weak operation] in
            if let strongOperation = operation {
                self.completionHandlerQueue.addOperationWithBlock {
                    completionHandler(strongOperation.error == nil, strongOperation.error)
                }
            }
        }
        operation.path = path
        if !path.hasSuffix("/") {
            operation.path = path + "/"
        }
        operationQueue.addOperation(operation)
    }
    
    /** 
    Downloads file at path from FTP server.
    File is stored in /tmp directory. Caller is responsible for deleting this file. */
    public func download(path: String, completionHandler: FileURLResultCompletionHandler) {
        let operation = FileDownloadOperation(configuration: configuration, queue: streamQueue)
        operation.completionBlock = {
            [weak operation] in
            if let strongOperation = operation {
                self.completionHandlerQueue.addOperationWithBlock {
                    completionHandler(strongOperation.fileURL, strongOperation.error)
                }
            }
        }
        operation.path = path
        operationQueue.addOperation(operation)
    }
    
    /** Uploads file from fileURL at path. */
    public func upload(fileURL: NSURL, path: String, completionHandler: BooleanResultCompletionHandler) {
        let operation = FileUploadOperation(configuration: configuration, queue: streamQueue)
        operation.completionBlock = {
            [weak operation] in
            if let strongOperation = operation {
                self.completionHandlerQueue.addOperationWithBlock {
                    completionHandler(strongOperation.error == nil, strongOperation.error)
                }
            }
        }
        operation.path = path
        operation.fileURL = fileURL
        operationQueue.addOperation(operation)
    }
}

public let kFTPAnonymousUser = "anonymous"

/** The session configuration. */
public struct SessionConfiguration {
    /**
    The host of FTP server. Defaults to `localhost`.
    Can be like this: 
        ftp://192.168.0.1
        127.0.0.1:21
        localhost
        ftp.mozilla.org
        ftp://ftp.mozilla.org:21
    */
    public var host: String = "localhost"
    
    /* Whether connection should be passive or not. Defaults to `true`. */
    public var passive = true
    
    /** The encoding of resource names. */
    public var encoding = NSUTF8StringEncoding
    
    /** The username for authorization. Defaults to `anonymous` */
    public var username = kFTPAnonymousUser
    
    /** The password for authorization. Can be empty. */
    public var password = ""
    
    public init() { }
    
    internal func URL() -> NSURL {
        var stringURL = host
        if !stringURL.hasPrefix("ftp://") {
            stringURL = "ftp://\(host)/"
        }
        if let url = NSURL(string: stringURL) {
            return url
        } else {
            return NSURL()
        }
    }
}

/** Not secure storage for Servers information. Information is storedin plist file in Cache directory.*/
private class SessionConfigurationStorage {
    
    /** The URL to plist file. */
    private let storageURL: NSURL
    
    init() {
        storageURL = NSURL(fileURLWithPath: "")
    }
    
    /** Returns an array of all stored servers. */
    private func allServers() {
        
    }
    
    /** Stores server. */
    private func storeServer() {
        
    }
    
    /** Deletes server. */
    private func deleteServer() {
        
    }
    
}

/** Stores credentials in Keychain. */
private class CredentialsStorage {
    
}
