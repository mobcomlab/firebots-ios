//
//  LoginViewController.swift
//  ParentsHero
//
//  Created by Admin on 10/4/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet var logoLabel: UILabel!
    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var loginButton: Button!
    @IBOutlet var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logoLabel.font = Style.Font.logoFont

        // Register UIKeyboardNotification
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        autoHideKeyboard()
    }
    
    deinit {
        // Unregister UIKeyboardNotification
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @IBAction func textFieldEditingChanged() {
        canLogin()
    }
    
    func canLogin() {
        if usernameTextField.text != "" {
            loginButton.enable()
        }
        else {
            loginButton.disable()
        }
    }
    
    @IBAction func loginPressed() {
        hideKeyboard()
        showIndicator(view: mainViewController.view, title: NSLocalizedString("Logging in", comment: ""))
        Auth.auth().signInAnonymously() { (user, error) in
            self.dismissIndicator(view: self.mainViewController.view)
            if let error = error as NSError? {
                // Login failed
                var title = NSLocalizedString("Login Failed", comment: "")
                switch (AuthErrorCode(rawValue: error.code)!) {
                case .networkError:
                    title = NSLocalizedString("Network Error", comment: "")
                    break
                default:
                    break
                }

                self.showOkAlert(title: title, message: error.localizedDescription)
            }
            else {
                // Login successful
                if let user = user {
                    FBUser.setupUser(uid: user.uid, username: self.usernameTextField.text!)
                    self.mainViewController.swapToChatroomViewController()
                }
            }
        }
    }
}

// MARK: UITextField delegate
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            usernameTextField.endEditing(true)
            return false
        default:
            return true
        }
    }
}

//// MARK: Keyboard + ScrollView handler
extension LoginViewController {
    
    /**
     Consider to scrolling view if keyboard overlab TextField.
     - parameter notification: NSNotification of keyboard
     */
    func keyboardWillShow(notification: NSNotification) {
        scrollViewForKeyboardWillShowNotification(scrollView: scrollView, notification: notification)
    }
    
    /**
     Reset ScrollView when keyboard hidden.
     - parameter notification: NSNotification of keyboard
     */
    func keyboardWillHide(notification: NSNotification) {
        scrollViewForKeyboardWillHideNotification(scrollView: scrollView, notification: notification)
    }
    
}
