//
//  FIRStorageCache.swift
//
//  Created by Ant on 28/12/2016.
//  Copyright © 2016 Apptitude. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class FIRStorageCache: DiskCache {
    
    static public var main: FIRStorageCache = FIRStorageCache(name: "firstoragecache")
    
    func get(storageReference: StorageReference, completion: @escaping (_ object: Data?) -> Void) {
        
        let filePath = self.filePath(storageReference: storageReference)
        
        get(filePath: filePath, completion: { object in
            if let object = object {
                // Cache hit
                DispatchQueue.main.async(execute: {
                    completion(object)
                })
                return
            }
            // Cache miss: download file
            storageReference.downloadURL(completion: { (url, error) in
                guard error == nil else {
                    print(error!.localizedDescription)
                    DispatchQueue.main.async(execute: {
                        completion(nil)
                    })
                    return
                }
                URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                    guard let httpURLResponse = response as? HTTPURLResponse,
                        httpURLResponse.statusCode == 200,
                        let data = data, error == nil else {
                            print(error?.localizedDescription ?? "Unknown error")
                            DispatchQueue.main.async(execute: {
                                completion(nil)
                            })
                            return
                    }
                    // Store result in cache
                    self.add(filePath: filePath, data: data, completion: {
                        DispatchQueue.main.async(execute: {
                            completion(data)
                        })
                    })
                }).resume()
            })
        })
    }
    
    func remove(storageReference: StorageReference) {
        remove(filePath: filePath(storageReference: storageReference))
    }
    
    private func filePath(storageReference: StorageReference) -> String {
        return "\(storageReference.bucket)/\(storageReference.fullPath)"
    }
}

class DiskCache {
    
    let name: String
    let cachePath: String
    var cacheDuration: TimeInterval = 3600 // 1 hour
    
    private let writeQueue: DispatchQueue
    private let readQueue: DispatchQueue
    private let fileManager: FileManager
    
    init(name: String) {
        self.name = name
        self.cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first! + "/" + name
        fileManager = FileManager()
        writeQueue = DispatchQueue(label: "write-\(name)", attributes: [])
        readQueue = DispatchQueue(label: "read-\(name)", attributes: [])
//        
//        #if DEBUG
//            cacheDuration = 60 // 60 seconds
//        #endif
    }
    
    internal func get(filePath: String, completion: @escaping (_ object: Data?) -> Void) {
        readQueue.async { [weak self] in
            guard let weakSelf = self else {
                completion(nil)
                return
            }
            
            let fullPath = "\(weakSelf.cachePath)/\(filePath)"
            if let attr = try? weakSelf.fileManager.attributesOfItem(atPath: fullPath),
                let modificationDate = attr[FileAttributeKey.modificationDate] as? Date,
                modificationDate.addingTimeInterval(weakSelf.cacheDuration).timeIntervalSinceNow > 0,
                let data = try? Data(contentsOf: URL(fileURLWithPath: fullPath)) {
                
                print("DiskCache: hit: \(filePath) \(modificationDate.addingTimeInterval(weakSelf.cacheDuration).timeIntervalSinceNow)")
                completion(data)
            }
            else {
                print("DiskCache: miss: \(filePath)")
                completion(nil)
            }
        }
    }
    
    internal func add(filePath: String, data: Data, completion: (() -> Void)? = nil) {
        writeQueue.async { [weak self] in
            guard let weakSelf = self else {
                completion?()
                return
            }
            
            if !weakSelf.fileManager.fileExists(atPath: weakSelf.cachePath) {
                do {
                    try weakSelf.fileManager.createDirectory(atPath: weakSelf.cachePath, withIntermediateDirectories: true, attributes: nil)
                } catch {}
            }
            
            let fullPath = "\(weakSelf.cachePath)/\(filePath)"
            
            let directoryPath = URL(fileURLWithPath: fullPath).deletingLastPathComponent().path
            if !weakSelf.fileManager.fileExists(atPath: directoryPath) {
                do {
                    try weakSelf.fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
                } catch {}
            }
            
            let attributes = [FileAttributeKey.modificationDate.rawValue: NSDate()]
            weakSelf.fileManager.createFile(atPath: fullPath, contents: data, attributes: attributes)
            print("DiskCache: saved: \(filePath)")
            completion?()
        }
    }
    
    internal func remove(filePath: String, completion: (() -> Void)? = nil) {
        writeQueue.async { [weak self] in
            guard let weakSelf = self else {
                completion?()
                return
            }
            
            let fullPath = "\(weakSelf.cachePath)/\(filePath)"
            do {
                try weakSelf.fileManager.removeItem(atPath: fullPath)
            } catch {}
            
            print("DiskCache: removed: \(filePath)")
            completion?()
        }
    }
    
}
