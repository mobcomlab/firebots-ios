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
    var lat: Double
    var long: Double
    var ref: DatabaseReference?
    
    init(id: String, lat: Double, long: Double) {
        self.id = id
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
        lat = snapshotValue[FBConstant.User.lat] as? Double ?? 0.0
        long = snapshotValue[FBConstant.User.lng] as? Double ?? 0.0
    }
    
    func toAnyObject() -> Any {
        return [
            FBConstant.User.lat: lat,
            FBConstant.User.lng: long
        ]
    }
}
