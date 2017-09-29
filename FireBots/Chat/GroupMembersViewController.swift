////
////  GroupMembersViewController.swift
////  ParentsHero
////
////  Created by Thanakorn Amnuaywiboolpol on 3/21/2560 BE.
////  Copyright © 2560 Admin. All rights reserved.
////
//
//import UIKit
//
//class GroupMembersViewController: UIViewController {
//    
//    @IBOutlet var tableView: UITableView!
//
//    var schoolName: String!
//    var teachers: [User] = []
//    var members: [User] = []
//    var bookingChildren: [String] = []
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "\(NSLocalizedString("Group Members", comment: "")) (\(members.count + teachers.count))"
//
//        tableView.tableFooterView = UIView(frame: CGRect.zero)
//        tableView.backgroundColor = Style.Color.background
//        
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        if Environment.appName == AppName.production {
//            AppAnalytics.track(screen: .chatGroupMember)
//        }
//
//    }
//}
//
//extension GroupMembersViewController: UITableViewDelegate, UITableViewDataSource {
//    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 2
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if section == 0 {
//            return teachers.count + 1
//        }
//        else {
//            return members.count + 1
//        }
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let section = indexPath.section
//        if section == 0 {
//            if indexPath.row == 0 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberHeaderCell", for: indexPath) as! GroupMemberHeaderCell
//                cell.titleLabel.text = NSLocalizedString("Teachers", comment: "")
//                return cell
//            }
//            
//            let teacher = teachers[indexPath.row - 1]
//            
//            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath) as! GroupMemberCell
//            
//            cell.setTeacher(teacher: teacher, schoolName: schoolName)
//            return cell
//        }
//        else {
//            if indexPath.row == 0 {
//                let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberHeaderCell", for: indexPath) as! GroupMemberHeaderCell
//                cell.titleLabel.text = NSLocalizedString("Parents", comment: "")
//                return cell
//            }
//            
//            let user = members[indexPath.row - 1]
//            var children: [Child] = []
//            
//            let cell = tableView.dequeueReusableCell(withIdentifier: "GroupMemberCell", for: indexPath) as! GroupMemberCell
//            
//            user.ref!.child(FBConstant.User.child).observeSingleEvent(of: .value, with: { (snapshot) in
//                if snapshot.childrenCount > 0 {
//                    let lastChild = Int(snapshot.childrenCount)
//                    var currentChild = 0
//                    for childSnapshot in snapshot.value as! [String: AnyObject] {
//                        currentChild += 1
//                        if self.bookingChildren.contains(childSnapshot.key) {
//                            FBChild.getChildRef().child(childSnapshot.key).observeSingleEvent(of: .value, with: { (snapshot) in
//                                if let child = Child(snapshot: snapshot) {
//                                    children.append(child)
//                                    if currentChild == lastChild {
//                                        cell.setUser(user: user, childrenString: self.setChildString(children: children))
//                                    }
//                                }
//                            })
//                        }
//                        else {
//                            if currentChild == lastChild {
//                                cell.setUser(user: user, childrenString: self.setChildString(children: children))
//                            }
//                        }
//                    }
//                }
//            })
//            return cell
//        }
//        
//    }
//    
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 44
//        }
//        
//        return 66
//    }
//    
//    private func setChildString(children: [Child]) -> String {
//        var childrenString = ""
//        for child in children {
//            if childrenString == "" {
//                childrenString = "\(child.name) \(child.age)"
//            }
//            else {
//                childrenString = "\(childrenString), \(child.name) \(child.age)"
//            }
//        }
//        return childrenString
//    }
//}
