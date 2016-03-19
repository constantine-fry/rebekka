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
        self.fileURL = NSURL(fileURLWithPath: filePath)
        do {
            try NSData().writeToURL(self.fileURL!, options: NSDataWritingOptions.DataWritingAtomic)
            self.fileHandle = try NSFileHandle(forWritingToURL: self.fileURL!)
            self.startOperationWithStream(self.readStream)
        } catch let error as NSError {
            self.error = error
            self.finishOperation()
        }
    }
    
    override func streamEventEnd(aStream: NSStream) -> (Bool, NSError?) {
        self.fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(aStream: NSStream) {
        super.streamEventError(aStream)
        self.fileHandle?.closeFile()
        if self.fileURL != nil {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(self.fileURL!)
            } catch _ {
            }
        }
        self.fileURL = nil
    }
    
    override func streamEventHasBytes(aStream: NSStream) -> (Bool, NSError?) {
        if let inputStream = aStream as? NSInputStream {
            var parsetBytes: Int = 0
            repeat {
                parsetBytes = inputStream.read(self.temporaryBuffer, maxLength: 1024)
                if parsetBytes > 0 {
                    autoreleasepool {
                        let data = NSData(bytes: self.temporaryBuffer, length: parsetBytes)
                        self.fileHandle!.writeData(data)
                    }
                }
            } while (parsetBytes > 0)
        }
        return (true, nil)
    }
}
