//
//  Message.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 2/23/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import JSQMessagesViewController

class Message: JSQMessage {
    var id: String
    var photoURL: String
    var sendingTime: Date
    var sendingTimeString: String
    var isFirstMessageOfDate: Bool
    
    init(id: String, senderID: String, displayName: String, text: String, sendingTime: Date, isFirstMessageOfDate: Bool) {
        self.id = id
        self.photoURL = ""
        self.sendingTime = sendingTime
        self.sendingTimeString = ""
        self.isFirstMessageOfDate = isFirstMessageOfDate
        super.init(senderId: senderID, senderDisplayName: displayName, date: sendingTime, text: text)
        self.getSendingTimeString()
    }
    
    init(id: String, senderID: String, displayName: String, media: JSQMessageMediaData, photoURL: String, sendingTime: Date, isFirstMessageOfDate: Bool) {
        self.id = id
        self.photoURL = photoURL
        self.sendingTime = sendingTime
        self.sendingTimeString = ""
        self.isFirstMessageOfDate = isFirstMessageOfDate
        super.init(senderId: senderID, senderDisplayName: displayName, date: sendingTime, media: media)
        self.getSendingTimeString()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getSendingTimeString() {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: sendingTime)
        let minute = calendar.component(.minute, from: sendingTime)
        
        sendingTimeString = String(format: "%02d:%02d", hour, minute)
    }
}
