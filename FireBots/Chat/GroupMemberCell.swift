////
////  GroupMemberCell.swift
////  ParentsHero
////
////  Created by Thanakorn Amnuaywiboolpol on 3/21/2560 BE.
////  Copyright © 2560 Admin. All rights reserved.
////
//
//import UIKit
//
//class GroupMemberCell: UITableViewCell {
//    
//    @IBOutlet var profileImageView: CircleImageView!
//    @IBOutlet var nameLabel: UILabel!
//    @IBOutlet var otherLabel: UILabel!
//
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        nameLabel.text = ""
//        otherLabel.text = ""
//    }
//    
//    func setUser(user: User, childrenString: String) {
//        if let ref = user.profileImageRef {
//            profileImageView.setCircleImage(storageReference: ref)
//        }
//        else {
//            profileImageView.defaultProfileImage()
//        }
//        nameLabel.text = user.displayName
//        otherLabel.text = childrenString
//    }
//    
//    func setTeacher(teacher: User, schoolName: String) {
//        if let ref = teacher.profileImageRef {
//            profileImageView.setCircleImage(storageReference: ref)
//        }
//        else {
//            profileImageView.defaultProfileImage()
//        }
//        nameLabel.text = teacher.displayName
//        otherLabel.text = schoolName
//    }
//}
