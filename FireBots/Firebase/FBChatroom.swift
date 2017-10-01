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
}
