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
    var fileURL: NSURL?
    
    override func start() {
        if let fileURL = fileURL {
            do {
                fileHandle = try NSFileHandle(forReadingFromURL: fileURL)
                startOperationWithStream(writeStream)
            } catch let error as NSError {
                self.error = error
                fileHandle = nil
                finishOperation()
            }
        }
    }
    
    override func streamEventEnd(aStream: NSStream) -> (Bool, NSError?) {
        fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(aStream: NSStream) {
        fileHandle?.closeFile()
    }
    
    override func streamEventHasSpace(aStream: NSStream) -> (Bool, NSError?) {
        if let fileHandle = fileHandle, writeStream = aStream as? NSOutputStream {
            let offsetInFile = fileHandle.offsetInFile
            let data = fileHandle.readDataOfLength(1024)
            let writtenBytes = writeStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
            if writtenBytes > 0 {
                fileHandle.seekToFileOffset(offsetInFile + UInt64(writtenBytes))
            } else if writtenBytes == -1 {
                finishOperation()
            }
        }
        return (true, nil)
    }
    
}
