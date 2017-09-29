//
//  SplashScreenViewController.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 12/7/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth

class SplashScreenViewController: UIViewController {
    
    enum VersionError: Error {
        case invalidResponse, invalidBundleInfo
    }
        
    @IBOutlet var splashScreenText: UILabel!
    
    let splashTimeOut = 3.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        splashScreenText.font = Style.Font.splashScreenFont
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        _ = Timer.scheduledTimer(timeInterval: splashTimeOut, target: self, selector: #selector(closeSplashScreen), userInfo: nil, repeats: false)

    }
    
    func closeSplashScreen() {
        if let user = Auth.auth().currentUser {
            FBUser.setupUID(uid: user.uid)
            mainViewController.swapToChatroomViewController()
        }
        else {
            mainViewController.swapToLoginViewController()
        }
    }

}
