//
//  CircleImageView.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 3/28/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import UIKit
import FirebaseStorage

class CircleImageView: UIImageView {
    
    var setCircleImageCallback: ((Bool) -> ())?
    
    override func awakeFromNib() {
        layer.cornerRadius = frame.size.width / 2
    }
    
    func defaultProfileImage() {
        image = UIImage(named: "ic_profile")
        self.setCircleImageCallback?(true)
    }
    
    func setCircleImage(storageReference: StorageReference) {
        FIRStorageCache.main.get(storageReference: storageReference) { data in
            if let data = data, let image = UIImage(data: data) {
                self.image = image
                self.setCircleImageCallback?(true)
            }
            else {
                self.setCircleImageCallback?(false)
            }
        }
    }
    
}
