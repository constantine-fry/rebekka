//
//  WriteStreamOperation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

/** The base class for write stream operatons. */
internal class WriteStreamOperation: StreamOperation {
    
    lazy var writeStream: NSOutputStream = {
        let url = self.fullURL()
        let cfStream = CFWriteStreamCreateWithFTPURL(nil, url)
        CFWriteStreamSetDispatchQueue(cfStream.takeUnretainedValue(), self.queue)
        let stream: NSOutputStream = cfStream.takeRetainedValue()
        return stream
    }()
    
    internal override func start() {
        startOperationWithStream(writeStream)
    }
}
