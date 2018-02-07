//
//  ResourceListOperation.swift
//  Rebekka
//
//  Created by Constantine Fry on 25/05/15.
//  Copyright (c) 2015 Constantine Fry. All rights reserved.
//

import Foundation

/* Resource type, values defined in `sys/dirent.h`. */
public enum ResourceType: String {
    case unknown        = "Unknown"        // DT_UNKNOWN
    case directory      = "Directory"      // DT_DIR
    case regularFile    = "RegularFile"    // DT_REG
    case symbolicLink   = "SymbolicLink"   // DT_LNK
    case namedPipe          = "NamedPipe"          // DT_FIFO
    case characterDevice    = "CharacterDevice"    // DT_CHR
    case blockDevice        = "BlockDevice"        // DT_BLK
    case localDomainSocket  = "LocalDomainSocket"  // DT_SOCK
    case whiteout           = "Whiteout"           // DT_WHT
    
    static func create(with fileType: Int) -> ResourceType? {
        switch fileType {
        case Int(DT_UNKNOWN): return .unknown
        case Int(DT_FIFO): return .namedPipe
        case Int(DT_SOCK): return .localDomainSocket
        case Int(DT_CHR): return .characterDevice
        case Int(DT_DIR): return .directory
        case Int(DT_BLK): return .blockDevice
        case Int(DT_REG): return .regularFile
        case Int(DT_LNK): return .symbolicLink
        case Int(DT_WHT): return .whiteout
        default:
            return nil
        }
    }
}

open class ResourceItem: CustomStringConvertible {
    open var type: ResourceType = .unknown
    open var name: String = ""
    open var link: String = ""
    open var date: Date = Date()
    open var size: Int = 0
    open var mode: Int = 0
    open var owner: String = ""
    open var group: String = ""
    open var path: String = "/"
    
    open var description: String {
        return "\nResourceItem: \(name), \(type.rawValue)"
    }
}

/** Operation for resource listing. */
internal class ResourceListOperation: ReadStreamOperation {
    
    fileprivate var inputData: NSMutableData?
    var resources: [ResourceItem]?
    
    override func streamEventEnd(_ aStream: Stream) -> (Bool, NSError?) {
        guard let inputData = inputData else {
            print("ERROR in ResourceListOperation.streamEventEnd: inputData was null")
            return (true, nil)
        }

        var offset = 0
        let bytes = inputData.bytes.bindMemory(to: UInt8.self, capacity: inputData.length)
        let totalBytes = CFIndex(self.inputData!.length)
        var parsedBytes = CFIndex(0)
        let entity = UnsafeMutablePointer<Unmanaged<CFDictionary>?>.allocate(capacity: 1)
        var resources = [ResourceItem]()
        repeat {
            parsedBytes = CFFTPCreateParsedResourceListing(nil, bytes.advanced(by: offset), totalBytes - offset, entity)
            if parsedBytes > 0 {
                let value = entity.pointee?.takeUnretainedValue()
                if let fptResource = value {
                    resources.append(self.mapFTPResources(fptResource))
                }
                offset += parsedBytes
            }
        } while parsedBytes > 0
        self.resources = resources
        entity.deinitialize()
        return (true, nil)
    }
    
    fileprivate func mapFTPResources(_ ftpResources: NSDictionary) -> ResourceItem {
        let item = ResourceItem()
        if let mode = ftpResources[kCFFTPResourceMode as String] as? Int {
            item.mode = mode
        }
        if let name = ftpResources[kCFFTPResourceName as String] as? String {
            // CFFTPCreateParsedResourceListing assumes that teh names are in MacRoman.
            // To fix it we create data from string and read it with correct encoding.
            // https://devforums.apple.com/message/155626#155626
            if configuration.encoding == String.Encoding.macOSRoman {
                item.name = name
            } else if let nameData = name.data(using: String.Encoding.macOSRoman) {
                if let encodedName = NSString(data: nameData, encoding: self.configuration.encoding.rawValue) {
                    item.name = encodedName as String
                }
            }
            item.path = self.path! + item.name
        }
        if let owner = ftpResources[kCFFTPResourceOwner as String] as? String {
            item.owner = owner
        }
        if let group = ftpResources[kCFFTPResourceGroup as String] as? String {
            item.group = group
        }
        if let link = ftpResources[kCFFTPResourceLink as String] as? String {
            item.link = link
        }
        if let size = ftpResources[kCFFTPResourceSize as String] as? Int {
            item.size = size
        }
        if let type = ftpResources[kCFFTPResourceType as String] as? Int {
            if let resourceType = ResourceType.create(with: type) {
                item.type = resourceType
            }
        }
        if let date = ftpResources[kCFFTPResourceModDate as String] as? Date {
            item.date = date
        }
        return item
    }
    
    override func streamEventHasBytes(_ aStream: Stream) -> (Bool, NSError?) {
        if let inputStream = aStream as? InputStream {
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 1024)
            let result = inputStream.read(buffer, maxLength: 1024)
            if result > 0 {
                if self.inputData == nil {
                    self.inputData = NSMutableData(bytes: buffer, length: result)
                } else {
                    self.inputData!.append(buffer, length: result)
                }
            }
            buffer.deinitialize()
        }
        return (true, nil)
    }
}
