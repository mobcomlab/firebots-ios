//
//  UIViewController+MainViewController.swift
//  ParentsHero
//
//  Created by Admin on 10/6/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth

extension UIViewController {
    
    var mainViewController: MainViewController {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
            let mainViewController = appDelegate.window?.rootViewController as? MainViewController else {
                assertionFailure()
                return MainViewController(viewController: UIViewController())
        }
        return mainViewController
    }
    
}

extension MainViewController {
        
    func swapToLoginViewController() {
        if let navController = currentViewController as? UINavigationController, navController.viewControllers[0].isKind(of: LoginViewController.self) {
            return
        }
        let loginStoryboard = UIStoryboard(name: "Login", bundle: Bundle.main)
        self.setViewController(newViewController: loginStoryboard.instantiateInitialViewController()!)
        FBUser.removeToken()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func swapToChatroomViewController() {
        let chatStoryboard = UIStoryboard(name: "Chat", bundle: Bundle.main)
        self.setViewController(newViewController: chatStoryboard.instantiateInitialViewController()!)
    }
}

