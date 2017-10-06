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
import CoreLocation

class ChatroomViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet var startChatButton: Button!
    @IBOutlet var chatroomNameTextField: UITextField!
    @IBOutlet var tableView: UITableView!
    
    var user: User?
    var chatrooms: [Chatroom] = []
    var chatroomKeys: [String] = []
    var members: [User] = []
    var chatroomID: String!
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 120, height: 40))
        label.textAlignment = .center
        label.font = Style.Font.navigationTitleFont
        label.text = "FIREBOTS"
        label.textColor = Style.Color.white
        navigationItem.titleView = label
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        FBUser.getUserRef().child(FBUser.uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let user = User(snapshot: snapshot) {
                self.user = user
                self.locationManager = CLLocationManager()
                self.locationManager.delegate = self;
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
                self.locationManager.requestAlwaysAuthorization()
                self.locationManager.startUpdatingLocation()
            }
            else {
                self.mainViewController.swapToLoginViewController()
            }
        })
        
        // Notification direct when press on notification type newMessage
        if let chatroomID = mainViewController.chatroomID {
            self.chatroomID = chatroomID
            mainViewController.chatroomID = nil
            startChat()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        
        FBChatroom.getChatroomRef().observe(.childAdded, with: { (snapshot) in
            if !self.chatroomKeys.contains(snapshot.key) {
                if let chatroom = Chatroom(snapshot: snapshot) {
                    self.chatroomKeys.append(chatroom.id)
                    self.chatrooms.append(chatroom)
                    self.tableView.insertRows(at: [IndexPath(row: self.chatrooms.count - 1, section: 0)], with: .automatic)
                }
            }
        })
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let chatViewController = segue.destination as? ChatViewController {
            chatViewController.chatroomID = chatroomID
            chatViewController.sender = user
            chatViewController.members = members
        }
    }
    
    @IBAction func logoutPressed() {
        mainViewController.swapToLoginViewController()
    }
    
    @IBAction func startGEOChatPressed() {
        guard let user = user, let lat = user.lat, let long = user.long, let chatroomName = chatroomNameTextField.text, chatroomName != "" else {
            return
        }
        showIndicator(view: mainViewController.view, title: "Loading")
        chatroomID = FBChatroom.getChatroomRef().childByAutoId().key
        let chatroom = Chatroom(id: chatroomID, name: chatroomName, lat: lat, long: long)
        FBChatroom.getChatroomRef().child(chatroomID).setValue(chatroom.toAnyObject())
        startChat()
    }
    
    func startChat() {
        FBChatroom.getChatroomRef().child(chatroomID).child(FBConstant.Chatroom.user).child(FBUser.uid).setValue(true)
        getMembers()
    }
    
    func getMembers() {
        FBChatroom.getChatroomRef().child(chatroomID).child(FBConstant.Chatroom.user).observeSingleEvent(of: .value, with: { (snapshot) in
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
                                self.dismissIndicator(view: self.mainViewController.view)
                                self.performSegue(withIdentifier: "ChatViewController", sender: nil)
                            }
                        })
                    }
                }
            }
            else {
                self.dismissIndicator(view: self.mainViewController.view)
                self.performSegue(withIdentifier: "ChatViewController", sender: nil)
            }
        })
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let user = user, let location = manager.location else {
            return
        }
        let latLng: CLLocationCoordinate2D = location.coordinate
        if let lat = user.lat, let long = user.long {
            if lat != latLng.latitude && long != latLng.longitude {
                self.user?.lat = latLng.latitude
                self.user?.long = latLng.longitude
                user.ref?.updateChildValues([
                    FBConstant.User.lat: latLng.latitude,
                    FBConstant.User.lng: latLng.longitude
                ])
            }
        }
        else {
            self.user?.lat = latLng.latitude
            self.user?.long = latLng.longitude
            user.ref?.updateChildValues([
                FBConstant.User.lat: latLng.latitude,
                FBConstant.User.lng: latLng.longitude
            ])
        }
        
        startChatButton.enable()
    }
}

extension ChatroomViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatroomCell", for: indexPath) as! ChatroomCell
        cell.roomNameLabel.text = chatrooms[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showIndicator(view: mainViewController.view, title: "Loading")
        chatroomID = chatrooms[indexPath.row].id
        getMembers()
    }
}
