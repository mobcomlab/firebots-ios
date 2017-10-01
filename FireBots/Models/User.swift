//
//  User.swift
//  ParentsHero
//
//  Created by Admin on 10/4/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import JSQMessagesViewController

struct User {
    
    let uid: String
    var username: String
    var lat: Double?
    var long: Double?
    var ref: DatabaseReference?
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
        self.lat = nil
        self.long = nil
        self.ref = nil
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snapshotValue = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        uid = snapshot.key
        ref = snapshot.ref
        username = snapshotValue[FBConstant.User.username] as? String ?? ""
        lat = snapshotValue[FBConstant.User.lat] as? Double ?? nil
        long = snapshotValue[FBConstant.User.lng] as? Double ?? nil
    }
    
    func toAnyObject() -> Any {
        if let lat = lat, let long = long {
            return [
                FBConstant.User.username: username,
                FBConstant.User.lat: lat,
                FBConstant.User.lng: long
            ]
        }
        return [
            FBConstant.User.username: username
        ]
    }
}
