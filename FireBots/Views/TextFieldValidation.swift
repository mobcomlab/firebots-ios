//
//  TextFieldValidation.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 3/7/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import UIKit

class TextFieldValidation: UITextField, UITextFieldDelegate {
    
    let padding = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 5);
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }

    // Add on
    weak var externalDelegate: UITextFieldDelegate?
    
    fileprivate var backupPlaceholder: String!
    fileprivate var topPlaceholderLabel: UILabel?
    fileprivate var detailMessageLabel: UILabel?
    
    // MARK: TextField properties
    
    @IBInspectable var errorMessage: String = "" {
        didSet {
            
            // Build error label
            let errorLabel = UILabel()
            errorLabel.frame = CGRect(x: CGFloat(24), y: self.frame.size.height-20, width: self.frame.size.width, height: 20)
            errorLabel.textColor = Style.Color.red
            errorLabel.font = Style.Font.textFieldErrorFont
            errorLabel.textAlignment = .left
            errorLabel.text = errorMessage
            errorLabel.isHidden = !invalidShowMessage
            
            if detailMessageLabel != nil {
                detailMessageLabel!.removeFromSuperview()
            }
            
            // Add error label to textField
            self.addSubview(errorLabel)
            
            //
            detailMessageLabel = errorLabel
            
        }
    }
    
    @IBInspectable var invalidShowMessage: Bool = true {
        didSet {
            // Set visibility for errorLabel
            detailMessageLabel?.isHidden = !invalidShowMessage
        }
    }
    
    func initTopPlaceholderLabel() {
        backupPlaceholder = NSLocalizedString(placeholder ?? "", comment: "")
        // Build error label
        let label = UILabel()
        label.frame = CGRect(x: CGFloat(24), y: 0, width: self.frame.size.width, height: 20)
        label.textColor = Style.Color.primary
        label.font = Style.Font.textFieldTopPlaceholderFont
        label.textAlignment = .left
        label.text = backupPlaceholder
        
        if topPlaceholderLabel != nil {
            topPlaceholderLabel!.removeFromSuperview()
        }
        
        // Add error label to textField
        self.addSubview(label)
        
        //
        topPlaceholderLabel = label
        shouldHiddenTopPlaceholderLabel()
    }
    
    // MARK: Override properties
    // Swizzle any external sets to set externalDelegate and reset to self
    override weak var delegate: UITextFieldDelegate? {
        didSet {
            if delegate == nil || !delegate!.isKind(of: TextFieldValidation.self) {
                externalDelegate = delegate
                delegate = self
            }
        }
    }
    
    // MARK: Intial
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        delegate = self
        initTopPlaceholderLabel()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        initTopPlaceholderLabel()
    }
    
    // MARK: Override
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
    }
    
    override var text: String? {
        didSet {
            shouldHiddenTopPlaceholderLabel()
        }
    }
    
    // MARK: TopPlaceholderLabel
    @IBInspectable var isHiddenTopPlaceholderLabel: Bool = false {
        didSet {
            shouldHiddenTopPlaceholderLabel()
        }
    }
    
    fileprivate func shouldHiddenTopPlaceholderLabel() {
        topPlaceholderLabel?.isHidden = true
//        if isHiddenTopPlaceholderLabel {
//            topPlaceholderLabel?.isHidden = true
//        }
//        else if let text = self.text, text.characters.count > 0 {
//            topPlaceholderLabel?.isHidden = false
//        }
//        else {
//            topPlaceholderLabel?.isHidden = true
//        }
    }
    
    // MARK: UITextField delegate and datasource
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        if let del = externalDelegate, del.responds(to: #selector(UITextFieldDelegate.textFieldShouldBeginEditing(_:))) {
            
            return del.textFieldShouldBeginEditing!(textField)
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if let del = externalDelegate, del.responds(to: #selector(UITextFieldDelegate.textFieldShouldEndEditing(_:))) {
            
            return del.textFieldShouldEndEditing!(textField)
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        // Should show top placeholder label
//        topPlaceholderLabel?.isHidden = isHiddenTopPlaceholderLabel
        placeholder = ""
        
        if let del = externalDelegate, del.responds(to: #selector(UITextFieldDelegate.textFieldDidBeginEditing(_:))) {
            
            del.textFieldDidBeginEditing!(textField)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        // Should show top placeholder label
        shouldHiddenTopPlaceholderLabel()
        if textField.text == "" {
            placeholder = backupPlaceholder
        }
        
        if let del = externalDelegate, del.responds(to: #selector(UITextFieldDelegate.textFieldDidEndEditing(_:))) {
            
            del.textFieldDidEndEditing!(textField)
        }
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let del = externalDelegate, del.responds(to: #selector(UITextFieldDelegate.textFieldShouldClear(_:))) {
            
            return del.textFieldShouldClear!(textField)
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let del = externalDelegate, del.responds(to: #selector(UITextFieldDelegate.textFieldShouldReturn(_:))) {
            
            return del.textFieldShouldReturn!(textField)
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let del = externalDelegate, del.responds(to: #selector(UITextFieldDelegate.textField(_:shouldChangeCharactersIn:replacementString:))) {
            
            return del.textField!(textField, shouldChangeCharactersIn: range, replacementString: string)
        }
        return true
    }
}
