//
//  Operation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

internal enum OperationState {
    case none
    case ready
    case executing
    case finished
}

/** The base class for FTP operations used in framework. */
internal class Operation: Foundation.Operation {
    
    var error: NSError?
    
    internal let configuration: SessionConfiguration
    
    internal var state = OperationState.ready {
        willSet {
            willChangeValue(forKey: "isReady")
            willChangeValue(forKey: "isExecuting")
            willChangeValue(forKey: "isFinished")
        }
        didSet {
            didChangeValue(forKey: "isReady")
            didChangeValue(forKey: "isExecuting")
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isAsynchronous: Bool { return true }
    override var isReady: Bool { return state == .ready }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
    
    init(configuration: SessionConfiguration) {
        self.configuration = configuration
    }
}
