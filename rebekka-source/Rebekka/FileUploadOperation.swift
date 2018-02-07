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
    fileprivate var fileHandle: FileHandle?
    var fileURL: URL!
    
    override func start() {
        do {
            fileHandle = try FileHandle(forReadingFrom: fileURL)
            startOperationWithStream(self.writeStream)
        } catch let error as NSError {
            self.error = error
            fileHandle = nil
            finishOperation()
        }
    }
    
    override func streamEventEnd(_ aStream: Stream) -> (Bool, NSError?) {
        fileHandle?.closeFile()
        return (true, nil)
    }
    
    override func streamEventError(_ aStream: Stream) {
        super.streamEventError(aStream)
        fileHandle?.closeFile()
    }
    
    override func streamEventHasSpace(_ aStream: Stream) -> (Bool, NSError?) {
        guard let fileHandle = fileHandle,
            let writeStream = aStream as? OutputStream else {
                return (true, nil)
        }
        let offsetInFile = fileHandle.offsetInFile
        let data = fileHandle.readData(ofLength: 1024)
        let bytesToWrite = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        let writtenBytes = writeStream.write(bytesToWrite, maxLength: data.count)
        if writtenBytes > 0 {
            self.fileHandle?.seek(toFileOffset: offsetInFile + UInt64(writtenBytes))
        } else if writtenBytes == -1 {
            self.finishOperation()
        }
        return (true, nil)
    }
    
}
