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
    
    var user: User?
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
            chatViewController.chatroomID = chatroomID
            chatViewController.sender = user
            chatViewController.members = members
        }
    }
    
    @IBAction func logoutPressed() {
        mainViewController.swapToLoginViewController()
    }
    
    @IBAction func startChatPressed() {
        guard let user = user, let lat = user.lat, let long = user.long else {
            return
        }
        chatroomID = FBChatroom.getChatroomRef().childByAutoId().key
        let chatroom = Chatroom(id: chatroomID, lat: lat, long: long)
        FBChatroom.getChatroomRef().child(chatroomID).setValue(chatroom.toAnyObject())
        FBChatroom.getChatroomRef().child(chatroomID).child(FBConstant.Chatroom.user).child(FBUser.uid).setValue(true)
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
