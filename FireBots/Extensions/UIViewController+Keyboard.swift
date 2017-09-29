//
//  UIViewController+Keyboard.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 11/17/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func autoHideKeyboard() {
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    func hideKeyboard() {
        self.resignFirstResponder()
        self.view.endEditing(true)
    }
    
    func scrollViewForKeyboardWillShowNotification(scrollView: UIScrollView, notification: NSNotification) {
        // Pull a bunch of info out of the notification
        guard let userInfo = notification.userInfo, let endValue = userInfo[UIKeyboardFrameEndUserInfoKey], let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] else {
                return
        }
        
        // Transform the keyboard's frame into our view's coordinate system
    
        let endRect = view.convert((endValue as AnyObject).cgRectValue, from: view.window)
        
        // Find out how much the keyboard overlaps the scroll view
        // We can do this because our scroll view's frame is already in our view's coordinate system
        let textFieldKeyboardSpace: CGFloat = 40.0
        let keyboardOverlap = scrollView.frame.maxY - endRect.origin.y + textFieldKeyboardSpace
        
        // Set the scroll view's content inset to avoid the keyboard
        // Don't forget the scroll indicator too!
        scrollView.contentInset.bottom = keyboardOverlap
        scrollView.scrollIndicatorInsets.bottom = keyboardOverlap
        
        let duration = (durationValue as AnyObject).doubleValue
        UIView.animate(withDuration: duration!, delay: 0, options: .beginFromCurrentState, animations: {
            
        }, completion: nil)
    }
    
    
    func scrollViewForKeyboardWillHideNotification(scrollView: UIScrollView, notification: NSNotification) {
        guard let userInfo = notification.userInfo,
            let durationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey] else {
                return
        }
        
        scrollView.contentInset.bottom = 0.0
        scrollView.scrollIndicatorInsets.bottom = 0.0
        scrollView.contentOffset.y = 0.0
        
        let duration = (durationValue as AnyObject).doubleValue
        UIView.animate(withDuration: duration!, delay: 0, options: .beginFromCurrentState, animations: {
            
        }, completion: nil)
    }
    
}

