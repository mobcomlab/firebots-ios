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
        static let lat = "lat"
        static let lng = "long"
        static let token = "token"
    }
    
    struct Chatroom {
        static let lat = "lat"
        static let lng = "long"
        static let message = "message"
        static let user = "user"
        static let typingIndicator = "typingIndicator"
    }
    
    struct Message {
        static let senderID = "senderId"
        static let senderName = "senderName"
        static let sendingTime = "sendingTime"
        static let text = "text"
        static let isBot = "isBot"
    }
}
