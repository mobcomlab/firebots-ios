//
//  ChatroomViewController.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 4/4/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import JSQMessagesViewController

class ChatroomViewController: UIViewController {
    
    var user: User?
    var members: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.textAlignment = .center
        label.font = Style.Font.navigationTitleFont
        label.text = "PARENTSHERO"
        label.textColor = Style.Color.white
        navigationItem.titleView = label
        
//        showIndicator(view: mainViewController.view, title: NSLocalizedString("Loading", comment: ""))
        
        // Notification direct when press on notification type newMessage
//        if let actvityID = mainViewController.activityID {
//            FBActivity.getActivityRef().child(actvityID).observeSingleEvent(of: .value, with: { (activitySnapshot) in
//                let activity = Activity(snapshot: activitySnapshot)
//                FBChatroom.getChatroomRef().child(activity.chatroomID).observeSingleEvent(of: .value, with: { (chatroomSnapshot) in
//                    self.chatroomSelected = Chatroom(snapshot: chatroomSnapshot, activity: activity)
//                    FBUser.getUserRef().child(FBUser.uid).observeSingleEvent(of: .value, with: { (userSnapshot) in
//                        self.user = User(snapshot: userSnapshot)
//                        self.getTechers()
//                    })
//                })
//            })
//        }
        
//        if let authUser = Auth.auth().currentUser {
//            dismissIndicator(view: self.mainViewController.view)
//            checkState()
//        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
//        if let chatViewController = segue.destination as? ChatViewController {
//            FBChatroom.removeMessageBadgeInChatroom(chatroomID: chatroomSelected.id, isTeacher: teacherIDs.contains(FBUser.uid))
//            chatViewController.chatroom = chatroomSelected
//            chatViewController.sender = user
//            chatViewController.teacherIDs = teacherIDs
//            chatViewController.teachers = teachers
//            chatViewController.members = members
//        }
    }
    
    @IBAction func logoutPressed() {
        mainViewController.swapToLoginViewController()
    }
    
//    func getMembers() {
//        FBChatroom.getChatroomRef().child(chatroomSelected.id).child(FBConstant.Chatroom.user).observeSingleEvent(of: .value, with: { (snapshot) in
//            if snapshot.childrenCount > 0 {
//                let lastChild = Int(snapshot.childrenCount)
//                var currentChild = 0
//                for chatroomUserSnapshot in snapshot.children {
//                    if let chatroomUserSnapshot = chatroomUserSnapshot as? DataSnapshot {
//                        FBUser.getUserRef().child(chatroomUserSnapshot.key).observeSingleEvent(of: .value, with: { (userSnpshot) in
//                            currentChild += 1
//                            if let member = User(snapshot: userSnpshot) {
//                                self.members.append(member)
//                            }
//                            if currentChild == lastChild {
//                                self.preapareMemberAvatarImage()
//                            }
//                        })
//                    }
//                }
//            }
//            else {
//                self.preapareMemberAvatarImage()
//            }
//        })
//    }
    
//    func preapareMemberAvatarImage() {
//        if members.count == 0 {
//            preapareTeacherAvatarImage()
//        }
//        var memberAvatarCompleted: [Bool] = []
//        for i in 0..<members.count {
//            if let ref = members[i].profileImageRef {
//                FIRStorageCache.main.get(storageReference: ref) { data in
//                    if let data = data, let image = UIImage(data: data) {
//                        self.members[i].avatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: image.crop(), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//                        memberAvatarCompleted.append(true)
//                    }
//                    else {
//                        self.members[i].avatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"ic_profile"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//                        memberAvatarCompleted.append(true)
//                    }
//                    if memberAvatarCompleted.count == self.members.count {
//                        self.preapareTeacherAvatarImage()
//                    }
//                }
//            }
//            else {
//                self.members[i].avatarImage = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named:"ic_profile"), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
//                memberAvatarCompleted.append(true)
//                if memberAvatarCompleted.count == self.members.count {
//                    self.preapareTeacherAvatarImage()
//                }
//            }
//        }
//    }
}
