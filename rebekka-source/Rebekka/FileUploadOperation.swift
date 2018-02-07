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
<<<<<<< HEAD
    private var fileHandle: NSFileHandle?
    var fileURL: NSURL?
=======
    fileprivate var fileHandle: FileHandle?
    var fileURL: URL!
>>>>>>> master_fvonk
    
    override func start() {
        guard let fileURL = fileURL else {
            error = NSError(domain: "streamEventError", code: 1, userInfo: nil)
            finishOperation()
            return
        }
        do {
<<<<<<< HEAD
            fileHandle = try NSFileHandle(forReadingFromURL: fileURL)
            startOperationWithStream(writeStream)
=======
            self.fileHandle = try FileHandle(forReadingFrom: fileURL)
            self.startOperationWithStream(self.writeStream)
>>>>>>> master_fvonk
        } catch let error as NSError {
            self.error = error
            fileHandle = nil
            finishOperation()
        }
    }
    
<<<<<<< HEAD
    override func streamEventEnd(aStream: NSStream) -> (Bool, NSError?) {
        fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(aStream: NSStream) {
        fileHandle?.closeFile()
    }
    
    override func streamEventHasSpace(aStream: NSStream) -> (Bool, NSError?) {
        guard let fileHandle = fileHandle, writeStream = aStream as? NSOutputStream else {
            return (true, nil)
        }
        let offsetInFile = fileHandle.offsetInFile
        let data = fileHandle.readDataOfLength(1024)
        let writtenBytes = writeStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        if writtenBytes > 0 {
            fileHandle.seekToFileOffset(offsetInFile + UInt64(writtenBytes))
        } else {
            finishOperation()
=======
    override func streamEventEnd(_ aStream: Stream) -> (Bool, NSError?) {
        self.fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(_ aStream: Stream) {
        super.streamEventError(aStream)
        self.fileHandle?.closeFile()
    }
    
    override func streamEventHasSpace(_ aStream: Stream) -> (Bool, NSError?) {
        if let writeStream = aStream as? OutputStream {
            let offsetInFile = self.fileHandle!.offsetInFile
            let data = self.fileHandle!.readData(ofLength: 1024)
            let writtenBytes = writeStream.write((data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count), maxLength: data.count)
            if writtenBytes > 0 {
                self.fileHandle?.seek(toFileOffset: offsetInFile + UInt64(writtenBytes))
            } else if writtenBytes == -1 {
                self.finishOperation()
            }
>>>>>>> master_fvonk
        }
        return (true, nil)
    }
    
}

