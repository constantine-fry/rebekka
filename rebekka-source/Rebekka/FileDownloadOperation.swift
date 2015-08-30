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
            let result = inputStream.read(self.temporaryBuffer, maxLength: 1024)
            if result > 0 {
                let data = NSData(bytes: self.temporaryBuffer, length: result)
                self.fileHandle!.writeData(data)
            }
        }
        return (true, nil)
    }
}