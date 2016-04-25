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
    case Unknown        = "Unknown"        // DT_UNKNOWN
    case Directory      = "Directory"      // DT_DIR
    case RegularFile    = "RegularFile"    // DT_REG
    case SymbolicLink   = "SymbolicLink"   // DT_LNK
    
    case NamedPipe          = "NamedPipe"          // DT_FIFO
    case CharacterDevice    = "CharacterDevice"    // DT_CHR
    case BlockDevice        = "BlockDevice"        // DT_BLK
    case LocalDomainSocket  = "LocalDomainSocket"  // DT_SOCK
    case Whiteout           = "Whiteout"           // DT_WHT
}

public class ResourceItem: CustomStringConvertible {
    public var type: ResourceType = .Unknown
    public var name: String = ""
    public var link: String = ""
    public var date: NSDate = NSDate()
    public var size: Int = 0
    public var mode: Int = 0
    public var owner: String = ""
    public var group: String = ""
    public var path: String = "/"
    
    public var description: String {
        get {
            return "\nResourceItem: \(name), \(type.rawValue)"
        }
    }
}


private let _resourceTypeMap: [Int:ResourceType] = [
    Int(DT_UNKNOWN): ResourceType.Unknown,
    Int(DT_FIFO):    ResourceType.NamedPipe,
    Int(DT_SOCK):    ResourceType.LocalDomainSocket,
    Int(DT_CHR): ResourceType.CharacterDevice,
    Int(DT_DIR): ResourceType.Directory,
    Int(DT_BLK): ResourceType.BlockDevice,
    Int(DT_REG): ResourceType.RegularFile,
    Int(DT_LNK): ResourceType.SymbolicLink,
    Int(DT_WHT): ResourceType.Whiteout
]

/** Operation for resource listing. */
internal class ResourceListOperation: ReadStreamOperation {
    
    private var inputData: NSMutableData?
    var resources: [ResourceItem]?
    
    override func streamEventEnd(aStream: NSStream) -> (Bool, NSError?) {
        guard let inputData = inputData else {
            print("ERROR in ResourceListOperation.streamEventEnd: inputData was null")
            return (true, nil)
        }
        var offset = 0
        let bytes = UnsafePointer<UInt8>(inputData.bytes)
        let totalBytes = CFIndex(inputData.length)
        var parsedBytes = CFIndex(0)
        let entity = UnsafeMutablePointer<Unmanaged<CFDictionary>?>.alloc(1)
        var resources = [ResourceItem]()
        repeat {
            parsedBytes = CFFTPCreateParsedResourceListing(nil, bytes.advancedBy(offset), totalBytes - offset, entity)
            if parsedBytes > 0 {
                let value = entity.memory?.takeUnretainedValue()
                if let ftpResource = value {
                    resources.append(mapFTPResources(ftpResource))
                }
                offset += parsedBytes
            }
        } while parsedBytes > 0
        self.resources = resources
        entity.destroy()
        return (true, nil)
    }
    
    private func mapFTPResources(ftpResources: NSDictionary) -> ResourceItem {
        let item = ResourceItem()
        if let mode = ftpResources[kCFFTPResourceMode as String] as? Int {
            item.mode = mode
        }
        if let name = ftpResources[kCFFTPResourceName as String] as? String {
            // CFFTPCreateParsedResourceListing assumes that teh names are in MacRoman.
            // To fix it we create data from string and read it with correct encoding.
            // https://devforums.apple.com/message/155626#155626
            if configuration.encoding == NSMacOSRomanStringEncoding {
                item.name = name
            } else if let nameData = name.dataUsingEncoding(NSMacOSRomanStringEncoding) {
                if let encodedName = NSString(data: nameData, encoding: self.configuration.encoding) {
                    item.name = encodedName as String
                }
            }
            if let path = path {
                item.path = path.stringByAppendingString(item.name)
            }
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
            if let resourceType = _resourceTypeMap[type] {
                item.type = resourceType
            }
        }
        if let date = ftpResources[kCFFTPResourceModDate as String] as? NSDate {
            item.date = date
        }
        return item
    }
    
    override func streamEventHasBytes(aStream: NSStream) -> (Bool, NSError?) {
        if let inputStream = aStream as? NSInputStream {
            let buffer = UnsafeMutablePointer<UInt8>.alloc(1024)
            let result = inputStream.read(buffer, maxLength: 1024)
            if result > 0 {
                if let inputData = inputData {
                    inputData.appendBytes(buffer, length: result)
                } else {
                    inputData = NSMutableData(bytes: buffer, length: result)
                }
            } else if result < 0 {
                print("ERROR in streamEventHasBytes: read result was \(result), expected > 0")
            }
            buffer.destroy()
        }
        return (true, nil)
    }
    
}
