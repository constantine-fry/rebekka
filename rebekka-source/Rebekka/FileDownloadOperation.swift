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
        let filePath = NSTemporaryDirectory().stringByAppendingPathComponent(NSUUID().UUIDString)
        self.fileURL = NSURL(fileURLWithPath: filePath)
        let written = NSData().writeToURL(self.fileURL!, options: NSDataWritingOptions.DataWritingAtomic, error: &error)
        self.fileHandle = NSFileHandle(forWritingToURL: self.fileURL!, error: &error)
        if (self.fileHandle == nil) {
            self.finishOperation()
        } else {
            self.startOperationWithStream(self.readStream)
        }
    }
    
    override func streamEventEnd(aStream: NSStream) -> (Bool, NSError?) {
        self.fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(aStream: NSStream) {
        self.fileHandle?.closeFile()
        if self.fileURL != nil {
            NSFileManager.defaultManager().removeItemAtURL(self.fileURL!, error: nil)
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