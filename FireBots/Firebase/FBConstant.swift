//
//  FBConstant.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 6/27/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import Foundation

struct FBConstant {
    
    struct Table {
        static let chatroom = "chatroom"
        static let user = "user"
    }
    
    struct User {
        static let username = "username"
        static let token = "token"
    }
    
    struct Chatroom {
        static let activityID = "activity_id"
        static let message = "message"
        static let user = "user"
        static let teacher = "teacher"
        static let read = "read"
        static let typingIndicator = "typingIndicator"
        struct ChatroomStatus {
            static let on = "on"
            static let off = "off"
        }
    }
    
    struct Message {
        static let senderID = "senderId"
        static let senderName = "senderName"
        static let sendingTime = "sendingTime"
        static let text = "text"
        static let photoURL = "photoURL"
        static let isFirstMessageOfDate = "isFirstMessageOfDate"
        static let new = "new"
        static let height = "height"
        static let width = "width"
    }
    
    static let order = "order"
    
    struct DynamicLink {
        static let ticket = "ticket"
        static let activityDetail = "activity_detail"
    }
}
