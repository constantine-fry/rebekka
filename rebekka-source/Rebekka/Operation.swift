//
//  Operation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

internal enum OperationState {
    case None
    case Ready
    case Executing
    case Finished
}

/** The base class for FTP operations used in framework. */
internal class Operation: NSOperation {

    var error: NSError?
    
    internal let configuration: SessionConfiguration
    
    internal var state = OperationState.Ready {
        willSet {
            willChangeValueForKey("isReady")
            willChangeValueForKey("isExecuting")
            willChangeValueForKey("isFinished")
        }
        didSet {
            didChangeValueForKey("isReady")
            didChangeValueForKey("isExecuting")
            didChangeValueForKey("isFinished")
        }
    }
    
    override var asynchronous: Bool { get { return true } }
    
    override var ready: Bool { get { return state == .Ready } }
    override var executing: Bool { get { return state == .Executing } }
    override var finished: Bool { get { return state == .Finished } }
    
    init(configuration: SessionConfiguration) {
        self.configuration = configuration
    }
}
