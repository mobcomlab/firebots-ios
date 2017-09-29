////
////  ChatroomCell.swift
////  ParentsHero
////
////  Created by Thanakorn Amnuaywiboolpol on 4/4/2560 BE.
////  Copyright © 2560 Admin. All rights reserved.
////
//
//import UIKit
//
//class ChatroomCell: UITableViewCell {
//    
//    @IBOutlet var activityImageView: CircleImageView!
//    @IBOutlet var activityNameLabel: UILabel!
//    @IBOutlet var schoolNameLabel: UILabel!
//    @IBOutlet var badgeView: UIView!
//    @IBOutlet var badgeLabel: UILabel!
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        
//        badgeView.layer.cornerRadius = 10
//        
//        activityNameLabel.text = " "
//        schoolNameLabel.text = " "
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//        if selected {
//            backgroundColor = Style.Color.lightGray
//            contentView.backgroundColor = Style.Color.lightGray
//        }
//        else {
//            backgroundColor = Style.Color.white
//            contentView.backgroundColor = Style.Color.white
//        }
//    }
//    
//    func setChatroom(chatroom: Chatroom, badgeNumber: Int) {
//        if let ref = chatroom.activityImageRef {
//            activityImageView.setCircleImage(storageReference: ref)
//        }
//        activityNameLabel.text = chatroom.activityName
//        schoolNameLabel.text = "\(NSLocalizedString("By", comment: "")) \(chatroom.schoolName)"
//        if badgeNumber > 0 {
//            self.showBadge(badgeNumber: badgeNumber)
//        }
//        else {
//            self.hideBadge()
//        }
//    }
//    
//    private func showBadge(badgeNumber: Int) {
//        badgeView.isHidden = false
//        badgeLabel.text = "\(badgeNumber)"
//    }
//    
//    private func hideBadge() {
//        badgeView.isHidden = true
//        badgeLabel.text = nil
//    }
//    
//}
