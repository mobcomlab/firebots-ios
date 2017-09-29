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
    var ref: DatabaseReference?
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
        self.ref = nil
    }
    
    init?(snapshot: DataSnapshot) {
        guard let snapshotValue = snapshot.value as? [String: AnyObject] else {
            return nil
        }
        uid = snapshot.key
        ref = snapshot.ref
        username = snapshotValue[FBConstant.User.username] as? String ?? ""
    }
    
    func toAnyObject() -> Any {
        return [
            FBConstant.User.username: username
        ]
    }
}
