//
//  UIViewController+Alert.swift
//  ParentsHero
//
//  Created by Admin on 10/6/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit
import SVProgressHUD

extension UIViewController {
    
    func showOkAlert(title: String?, message: String, completion: ((Void) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (action) -> Void in
            if let completion = completion {
                completion()
            }
        }
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func showAlert(title: String?, message: String, buttonText: String, dismissWithBackgroundTap: Bool = true, completion: ((Void) -> Void)?) {
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)

        if let title = title {
            let attributedTitle = NSAttributedString(string: title, attributes: [
                NSFontAttributeName : Style.Font.alertTitleFont,
                NSForegroundColorAttributeName : Style.Color.textNormal
            ])
            alertController.setValue(attributedTitle, forKey: "attributedTitle")
        }
        
        let attributedMessage = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : Style.Font.alertMessageFont,
            NSForegroundColorAttributeName : Style.Color.textNormal
        ])
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        
        let okAction = UIAlertAction(title: buttonText, style: .default) { (action) -> Void in
            if let completion = completion {
                completion()
            }
        }
        alertController.addAction(okAction)
        alertController.preferredAction = okAction
        self.present(alertController, animated: true, completion: {
            if dismissWithBackgroundTap {
                alertController.view.superview?.isUserInteractionEnabled = true
                alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
            }
        })
        alertController.view.tintColor = Style.Color.secondary
    }
    
    func showYesNoAlert(title: String, message: String, positiveButtonText: String?, negativeButtonText: String?, positiveCompletion: ((Void) -> Void)?, negativeCompletion: ((Void) -> Void)?, dismissWithBackgroundTap: Bool = false) {
        let attributedTitle = NSAttributedString(string: title, attributes: [
            NSFontAttributeName : Style.Font.alertTitleFont,
            NSForegroundColorAttributeName : Style.Color.textNormal
            ])
        let attributedMessage = NSAttributedString(string: message, attributes: [
            NSFontAttributeName : Style.Font.alertMessageFont,
            NSForegroundColorAttributeName : Style.Color.textNormal
            ])
        
        let alertController = UIAlertController(title: "", message: "", preferredStyle: .alert)
        
        alertController.setValue(attributedTitle, forKey: "attributedTitle")
        alertController.setValue(attributedMessage, forKey: "attributedMessage")
        let positiveAction = UIAlertAction(title: positiveButtonText ?? NSLocalizedString("Yes", comment: ""), style: .default) { (action) -> Void in
            if let completion = positiveCompletion {
                completion()
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        let negativeAction = UIAlertAction(title: negativeButtonText ?? NSLocalizedString("No", comment: ""), style: .cancel) { (action) -> Void in
            if let completion = negativeCompletion {
                completion()
            }
            else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        alertController.addAction(positiveAction)
        alertController.addAction(negativeAction)
        self.present(alertController, animated: true, completion: {
            if dismissWithBackgroundTap {
                alertController.view.superview?.isUserInteractionEnabled = true
                alertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose)))
            }
        })
    }
    
    func showErrorAlert(_ error: NSError, completion: ((Void) -> Void)?) {
        if let completion = completion{
            showOkAlert(title: error.localizedFailureReason, message: error.localizedRecoverySuggestion ?? error.localizedDescription, completion: completion)
        }
        else {
            showOkAlert(title: error.localizedFailureReason, message: error.localizedRecoverySuggestion ?? error.localizedDescription)
        }
    }
    
    func showTimeoutAlert() {
        showOkAlert(title: NSLocalizedString("Timeout", comment: ""), message: NSLocalizedString("Unable to complete the request", comment: ""))
    }
    
    func showNoCameraAlert(){
        showOkAlert(title: NSLocalizedString("No Camera", comment: ""), message: NSLocalizedString("Sorry, this device has no camera", comment: ""))
    }
    
    func showIndicator(view: UIView, title: String?) {
        SVProgressHUD.show(withStatus: title ?? "")
        view.isUserInteractionEnabled = false
    }
    
    func dismissIndicator(view: UIView) {
        SVProgressHUD.dismiss()
        view.isUserInteractionEnabled = true
    }
    
    func alertClose(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
