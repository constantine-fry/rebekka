//
//  Any+Syncronized.swift
//  Rebekka
//
//  Created by Martin Eberl on 07.02.18.
//  Copyright © 2018 Constantine Fry. All rights reserved.
//

import Foundation

public func synchronized(_ lock: Any, _ closure: () -> Void) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock)
}
