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
    
    @IBOutlet var startChatButton: Button!
    
    var user: User?
    var members: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.textAlignment = .center
        label.font = Style.Font.navigationTitleFont
        label.text = "THE HEROS"
        label.textColor = Style.Color.white
        navigationItem.titleView = label
        
        startChatButton.enable()

        
        FBUser.getUserRef().child(FBUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = User(snapshot: snapshot) {
                self.user = user
            }
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let chatViewController = segue.destination as? ChatViewController {
            chatViewController.sender = user
            chatViewController.members = members
        }
    }
    
    @IBAction func logoutPressed() {
        mainViewController.swapToLoginViewController()
    }
    
    @IBAction func startChatPressed() {
        FBChatroom.getChatroomRef().child(FBConstant.Chatroom.user).child(FBUser.uid).setValue(true)
        getMembers()
    }
    
    func getMembers() {
        FBChatroom.getChatroomRef().child(FBConstant.Chatroom.user).observeSingleEvent(of: .value, with: { (snapshot) in
            if snapshot.childrenCount > 0 {
                let lastChild = Int(snapshot.childrenCount)
                var currentChild = 0
                for chatroomUserSnapshot in snapshot.children {
                    if let chatroomUserSnapshot = chatroomUserSnapshot as? DataSnapshot {
                        FBUser.getUserRef().child(chatroomUserSnapshot.key).observeSingleEvent(of: .value, with: { (userSnpshot) in
                            currentChild += 1
                            if let member = User(snapshot: userSnpshot) {
                                self.members.append(member)
                            }
                            if currentChild == lastChild {
                                self.performSegue(withIdentifier: "ChatViewController", sender: nil)
                            }
                        })
                    }
                }
            }
            else {
                self.performSegue(withIdentifier: "ChatViewController", sender: nil)
            }
        })
    }
}
