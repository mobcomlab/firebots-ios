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
    
    init(uid: String, username: String) {
        self.uid = uid
        self.username = username
    }
    
    func toAnyObject() -> Any {
        return [
            FBConstant.User.username: username
        ]
    }
}
