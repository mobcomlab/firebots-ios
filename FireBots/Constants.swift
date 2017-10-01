//
//  Constants.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 10/25/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import Foundation
import UIKit

struct FormState {
    static let new = "new"
    static let edit = "edit"
}

struct LoadState {
    static let loading = "loading"
    static let loaded = "loaded"
}

struct NotificationType {
    static let type = "type"
    static let chatroomInvitation = "chatroomInvitation"
    static let newMessage = "newMessage"
}

struct NotificationExtra {
    static let chatroomID = "chatroomID"
    static let userID = "userID"
    static let badge = "badge"
}
