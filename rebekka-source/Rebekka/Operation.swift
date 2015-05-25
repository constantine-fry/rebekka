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
            self.willChangeValueForKey("isReady")
            self.willChangeValueForKey("isExecuting")
            self.willChangeValueForKey("isFinished")
        }
        didSet {
            self.didChangeValueForKey("isReady")
            self.didChangeValueForKey("isExecuting")
            self.didChangeValueForKey("isFinished")
        }
    }
    
    override var asynchronous: Bool { get { return true } }
    
    override var ready: Bool { get { return self.state == .Ready } }
    override var executing: Bool { get { return self.state == .Executing } }
    override var finished: Bool { get { return self.state == .Finished } }
    
    init(configuration: SessionConfiguration) {
        self.configuration = configuration
    }
}
