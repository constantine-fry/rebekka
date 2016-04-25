//
//  FileDownloadOperation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

/** Operation for downloading a file from FTP server. */
internal class FileDownloadOperation: ReadStreamOperation {
    
    private var fileHandle: NSFileHandle?
    var fileURL: NSURL?
    
    override func start() {
        let filePath = (NSTemporaryDirectory() as NSString).stringByAppendingPathComponent(NSUUID().UUIDString)
        fileURL = NSURL(fileURLWithPath: filePath)
        guard let fileURL = fileURL else {
            error = NSError(domain: "streamEventError", code: 1, userInfo: nil)
            finishOperation()
            return
        }
        do {
            try NSData().writeToURL(fileURL, options: NSDataWritingOptions.DataWritingAtomic)
            fileHandle = try NSFileHandle(forWritingToURL: fileURL)
            startOperationWithStream(readStream)
        } catch let error as NSError {
            self.error = error
            fileHandle = nil
            finishOperation()
        }
    }

    override func streamEventEnd(aStream: NSStream) -> (Bool, NSError?) {
        fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(aStream: NSStream) {
        fileHandle?.closeFile()
        if let fileURL = fileURL {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(fileURL)
            } catch _ {
            }
        }
        error = NSError(domain: "streamEventError", code: 0, userInfo: nil)
        fileURL = nil
    }
    
    override func streamEventHasBytes(aStream: NSStream) -> (Bool, NSError?) {
        var parsedBytes: Int = 0
        repeat {
            parsedBytes = 0
            if let inputStream = aStream as? NSInputStream {
                if inputStream.hasBytesAvailable && inputStream.streamStatus == NSStreamStatus.Open && inputStream.streamError == nil {
                    parsedBytes = inputStream.read(temporaryBuffer, maxLength: 1024)
                }
                if parsedBytes > 0 {
                    autoreleasepool {
                        let data = NSData(bytes: temporaryBuffer, length: parsedBytes)
                        fileHandle?.writeData(data)
                    }
                }
            }
        } while (parsedBytes > 0)
        
        return (true, nil)
    }
}
