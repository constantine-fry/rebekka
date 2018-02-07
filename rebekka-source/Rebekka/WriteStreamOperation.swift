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
    
    lazy var writeStream: OutputStream = {
        let cfStream = CFWriteStreamCreateWithFTPURL(nil, fullURL as CFURL)
        CFWriteStreamSetDispatchQueue(cfStream.takeUnretainedValue(), queue)
        return cfStream.takeRetainedValue()
    }()
    
    internal override func start() {
        startOperationWithStream(self.writeStream)
    }
}

