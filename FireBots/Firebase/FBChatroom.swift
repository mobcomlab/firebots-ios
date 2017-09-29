//
//  FBChatroom.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 7/14/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseStorage

class FBChatroom {
    
    static func getChatroomRef() -> DatabaseReference {
        return Database.database().reference().child(FBConstant.Table.chatroom)
    }
    
    static func getChatroomStorageRef() -> StorageReference {
        return Storage.storage().reference().child(FBConstant.Table.chatroom)
    }
    
    static func removeMessage(message: Message) {
        if (message.isMediaMessage) {
            let mediaStorage = Storage.storage().reference(forURL: message.photoURL)

            mediaStorage.delete { error in
                if let error = error {
                    // handle error
                    print(error)
                } else {
                    getChatroomRef().child(FBConstant.Chatroom.message).child(message.id).removeValue()
                }
            }
        } else {
            getChatroomRef().child(FBConstant.Chatroom.message).child(message.id).removeValue();
        }
    }
    
    static func updateChatroomUserRead(messageID: String) {
        let chatroomUserReadUpdate = [FBUser.uid: messageID]
        getChatroomRef().child(FBConstant.Chatroom.read).updateChildValues(chatroomUserReadUpdate)
    }
    
    static func removeChatroomUserRead() {
        getChatroomRef().child(FBConstant.Chatroom.read).removeValue();
    }
}
