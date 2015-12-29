//
//  FileUploadOperation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

/** Operation for file uploading. */
internal class FileUploadOperation: WriteStreamOperation {
    private var fileHandle: NSFileHandle?
    var fileURL: NSURL!
    
    override func start() {
        do {
            self.fileHandle = try NSFileHandle(forReadingFromURL: fileURL)
            self.startOperationWithStream(self.writeStream)
        } catch let error as NSError {
            self.error = error
            self.fileHandle = nil
            self.finishOperation()
        }
    }
    
    override func streamEventEnd(aStream: NSStream) -> (Bool, NSError?) {
        self.fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(aStream: NSStream) {
        self.fileHandle?.closeFile()
    }
    
    override func streamEventHasSpace(aStream: NSStream) -> (Bool, NSError?) {
        if let writeStream = aStream as? NSOutputStream {
            let offsetInFile = self.fileHandle!.offsetInFile
            let data = self.fileHandle!.readDataOfLength(1024)
            let writtenBytes = writeStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
            if writtenBytes > 0 {
                self.fileHandle?.seekToFileOffset(offsetInFile + UInt64(writtenBytes))
            } else if writtenBytes == -1 {
                self.finishOperation()
            }
        }
        return (true, nil)
    }
    
}
