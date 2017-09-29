//
//  InputValidation.swift
//  ParentsHero
//
//  Created by Thanakorn Amnuaywiboolpol on 3/2/2560 BE.
//  Copyright © 2560 Admin. All rights reserved.
//

import Foundation

/**
 Validator to check validation for TextField input.
 */
struct InputValidation {
    
//    public typealias ValidationCompletion = (ValidationResult) -> Void
    static let minPasswordCharacters = 8
    
    /**
     Perform a validation on an input with options
     - parameter input: the string to be validated
     - parameter options: an array of criteria for the validation
     - parameter completion: completion handler after validation
     */
    static func valid(_ input: String, options: [ValidationOption]) -> (isValid: Bool, message: String?) {
        
        for option in options {
            switch option {
            case .required:
                let result = validRequired(input)
                if !result.isValid {
                    return result
                }
            case .contactNo:
                let result = validContactNo(input)
                if !result.isValid {
                    return result
                }
            case .email:
                let validation = validEmail(input)
                if !validation.isValid {
                    return validation
                }
            case .password:
                let validation = validPassword(input)
                if !validation.isValid {
                    return validation
                }
            case .numerical:
                let validation = validNumerical(input)
                if !validation.isValid {
                    return validation
                }
            }
        }
        
        return (true, nil)
    }
    
    static func validRequired(_ input: String) -> (isValid: Bool, message: String?) {
        if input == "" {
            return (false, "Required field")
        }
        return (true, nil)
    }
    
    static func validContactNo(_ input: String) -> (isValid: Bool, message: String?) {
        if input.characters.count != 10 {
            return (false, "Invalid contact No")
        }
        return (true, nil)
    }
    
    static func validEmail(_ input: String) -> (isValid: Bool, message: String?) {
        
        // Email pattern
        let emailReg = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailReg)
        // Checkup input match with pattern
        if emailTest.evaluate(with: input) {
            return (true, nil)
        }
        else {
            return (false, "Invalid email")
        }
    }
    
    static func validPassword(_ input: String) -> (isValid: Bool, message: String?) {
        
        if input.characters.count < minPasswordCharacters {
            return (false, "Please enter a password of at least \(minPasswordCharacters) characters")
        }
        else {
            return (true, nil)
        }
    }
    
    static func validNumerical(_ input: String) -> (isValid: Bool, message: String?) {
        
        if let _ = Double(input) {
            return (true, nil)
        }
        
        return (false, "Invalid numerical")
    }
}
