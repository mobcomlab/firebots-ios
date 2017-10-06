//
//  ChatroomCell.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 4/4/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import UIKit

class ChatroomCell: UITableViewCell {
    
    @IBOutlet var roomNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        roomNameLabel.text = " "
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected {
            backgroundColor = Style.Color.lightGray
            contentView.backgroundColor = Style.Color.lightGray
        }
        else {
            backgroundColor = Style.Color.white
            contentView.backgroundColor = Style.Color.white
        }
    }
}
