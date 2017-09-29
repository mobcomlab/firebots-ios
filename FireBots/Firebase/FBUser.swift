//
//  FBUser.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 7/14/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import FirebaseInstanceID

class FBUser {
    
    static var uid = ""
    
    static func getUserRef() -> DatabaseReference {
        return Database.database().reference().child(FBConstant.Table.user)
    }
    
    static func getUserStorageRef() -> StorageReference {
        return Storage.storage().reference().child(FBConstant.Table.user)
    }
    
    static func setupUID(uid: String) {
        self.uid = uid
        addToken()
    }
    
    static func setupUser(uid: String, username: String) {
        self.uid = uid
        let user = User(uid: uid, username: username)
        getUserRef().child(uid).setValue(user.toAnyObject())
        addToken()
    }
    
    static private func addToken() {
        if let refreshedToken = InstanceID.instanceID().token() {
            if Auth.auth().currentUser != nil {
                let userUpdate = [FBConstant.User.token: refreshedToken]
                getUserRef().child(uid).updateChildValues(userUpdate)
            }
        }
    }
    
    static func removeToken() {
        if let user = Auth.auth().currentUser {
            getUserRef().child(uid).child(FBConstant.User.token).removeValue()
            if user.isAnonymous {
                uid = ""
                user.delete(completion: nil)
                getUserRef().child(user.uid).removeValue()
                try! Auth.auth().signOut()
            }
            else {
                uid = ""
                try! Auth.auth().signOut()
            }
        }
        else {
            uid = ""
            try! Auth.auth().signOut()
        }
    }
}
