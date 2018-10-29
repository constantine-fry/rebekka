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

    var progressBlock: ProgressHandler?

    fileprivate var totalSize: Double = 0
    fileprivate var doneSize: Double = 0

    override func start() {
        do {
            let path = fileURL.path
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: path)
            totalSize = (fileAttributes[FileAttributeKey.size] as AnyObject).doubleValue ?? 0
            self.fileHandle = try FileHandle(forReadingFrom: fileURL)
            self.startOperationWithStream(self.writeStream)
        } catch let error as NSError {
            self.error = error
            self.fileHandle = nil
            self.finishOperation()
        }
    }

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
                self.doneSize += Double(writtenBytes)
                self.fileHandle?.seek(toFileOffset: offsetInFile + UInt64(writtenBytes))
                if self.totalSize > 0 {
                    progressBlock?(self.doneSize / self.totalSize)
                }
            } else if writtenBytes == -1 {
                self.finishOperation()
            }
        }
        return (true, nil)
    }
    
}
