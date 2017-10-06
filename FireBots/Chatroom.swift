//
//  Chatroom.swift
//  FireBots
//
//  Created by Thanakorn Amnuaywiboolpol on 10/1/2560 BE.
//  Copyright © 2560 Mobile Computing Lab. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Chatroom {
    
    let id: String
    let name: String
    var lat: Double
    var long: Double
    var ref: DatabaseReference?
    
    init(id: String, name: String, lat: Double, long: Double) {
        self.id = id
        self.name = name
        self.lat = lat
        self.long = long
        self.ref = nil
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snapshotValue = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        id = snapshot.key
        ref = snapshot.ref
        name = snapshotValue[FBConstant.Chatroom.name] as? String ?? ""
        lat = snapshotValue[FBConstant.Chatroom.lat] as? Double ?? 0.0
        long = snapshotValue[FBConstant.Chatroom.lng] as? Double ?? 0.0
    }
    
    func toAnyObject() -> Any {
        return [
            FBConstant.Chatroom.name: name,
            FBConstant.Chatroom.lat: lat,
            FBConstant.Chatroom.lng: long
        ]
    }
}
