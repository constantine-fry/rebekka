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
        stream.setProperty(self.configuration.passive, forKey: kCFStreamPropertyFTPUsePassiveMode as String)
        stream.setProperty(self.configuration.username, forKey: kCFStreamPropertyFTPUserName as String)
        stream.setProperty(self.configuration.password, forKey: kCFStreamPropertyFTPPassword as String)
        stream.delegate = self
    }
    
    func fullURL() -> NSURL {
        if self.path != nil {
            return self.configuration.URL().URLByAppendingPathComponent(path!)
        }
        return self.configuration.URL()
    }
    
    @objc func stream(aStream: NSStream, handleEvent eventCode: NSStreamEvent) {
        if self.cancelled {
            streamEventError(aStream)
            self.error = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
            self.finishOperation()
            return
        }
        
        switch (eventCode) {
        case NSStreamEvent.OpenCompleted:
            streamEventOpenComleted(aStream)
        case NSStreamEvent.HasBytesAvailable:
            streamEventHasBytes(aStream)
        case NSStreamEvent.HasSpaceAvailable:
            streamEventHasSpace(aStream)
        case NSStreamEvent.ErrorOccurred:
            streamEventError(aStream)
            self.finishOperation()
        case NSStreamEvent.EndEncountered:
            streamEventEnd(aStream)
            self.finishOperation()
        default:
            print("Unkonwn NSStreamEvent: \(eventCode)")
        }
    }
    
    func startOperationWithStream(aStream: NSStream) {
        self.currentStream = aStream
        self.configureStream(self.currentStream!)
        self.currentStream!.open()
        self.state = .Executing
    }
    
    func finishOperation() {
        self.currentStream?.close()
        self.currentStream = nil
        self.state = .Finished
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
        self.error = aStream.streamError
    }
}
