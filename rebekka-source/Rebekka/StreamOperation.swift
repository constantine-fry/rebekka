//
//  StreamOperation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

/** The base class for stream operations. */
internal class StreamOperation: Operation, NSStreamDelegate {
    var path: String?
    internal let queue: dispatch_queue_t
    
    private var currentStream: NSStream?
    
    init(configuration: SessionConfiguration, queue: dispatch_queue_t) {
        self.queue = queue
        super.init(configuration: configuration)
    }
    
    private func configureStream(stream: NSStream) {
        stream.setProperty(true, forKey: kCFStreamPropertyShouldCloseNativeSocket as String)
        stream.setProperty(true, forKey: kCFStreamPropertyFTPFetchResourceInfo as String)
        stream.setProperty(configuration.passive, forKey: kCFStreamPropertyFTPUsePassiveMode as String)
        stream.setProperty(configuration.username, forKey: kCFStreamPropertyFTPUserName as String)
        stream.setProperty(configuration.password, forKey: kCFStreamPropertyFTPPassword as String)
        stream.delegate = self
    }
    
    func fullURL() -> NSURL {
        if let path = path {
            return configuration.URL().URLByAppendingPathComponent(path)
        }
        return configuration.URL()
    }
    
    @objc func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if cancelled {
            streamEventError(aStream)
            error = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
            finishOperation()
            return
        }
        
        switch eventCode {
        case NSStreamEvent.OpenCompleted:
            streamEventOpenComleted(aStream)
        case NSStreamEvent.HasBytesAvailable:
            streamEventHasBytes(aStream)
        case NSStreamEvent.HasSpaceAvailable:
            streamEventHasSpace(aStream)
        case NSStreamEvent.ErrorOccurred:
            streamEventError(aStream)
            finishOperation()
        case NSStreamEvent.EndEncountered:
            streamEventEnd(aStream)
            finishOperation()
        default:
            print("Unkonwn NSStreamEvent: \(eventCode)")
        }
    }
    
    func startOperationWithStream(aStream: NSStream) {
        currentStream = aStream
        if let currentStream = currentStream {
            configureStream(currentStream)
            currentStream.open()
        }
        state = .Executing
    }
    
    func finishOperation() {
        NSThread.sleepForTimeInterval(0.1)
        currentStream?.close()
        currentStream = nil
        state = .Finished
    }
    
    func streamEventOpenComleted(aStream: NSStream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventEnd(aStream: NSStream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventHasBytes(aStream: NSStream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventHasSpace(aStream: NSStream) -> (Bool, NSError?) {
        return (true, nil)
    }
    
    func streamEventError(aStream: NSStream) {
        error = aStream.streamError
    }
}
