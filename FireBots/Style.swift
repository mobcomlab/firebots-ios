//
//  Style.swift
//  ParentsHero
//
//  Created by Admin on 10/4/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit
import SVProgressHUD

struct Style {
    
    // MARK: Constants
    
    struct Font {
        
        static let splashScreenFont = UIFont(name: "BebasNeue", size: 45)!
        static let logoFont = UIFont(name: "BebasNeue", size: 36)!
        static let navigationTitleFont = UIFont(name: "BebasNeue", size: 24)!
        static let navigationTitleCustomFont = UIFont(name: "HelveticaNeue-Bold", size: 16)!
        static let exploreSectionFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
        static let chatGroupMemberSectionFont = UIFont(name: "HelveticaNeue-Bold", size: 16)!
        static let alertTitleFont = UIFont(name: "HelveticaNeue-Bold", size: 16)!
        static let alertMessageFont = UIFont(name: "HelveticaNeue", size: 15)!
        static let textFieldTopPlaceholderFont = UIFont(name: "HelveticaNeue", size: 10)!
        static let textFieldErrorFont = UIFont(name: "HelveticaNeue", size: 10)!
        static let progressHUDFont = UIFont(name: "HelveticaNeue-Medium", size: 18)!
        static let chatSenderNameFont = UIFont(name: "HelveticaNeue", size: 12)!
        static let chatTextMessageFont = UIFont(name: "HelveticaNeue", size: 18)!
        static let chatGalleryFont = UIFont(name: "HelveticaNeue", size: 10)!
        static let bankAccountTitleFont = UIFont(name: "HelveticaNeue", size: 13)!
        static let bankAccountFont = UIFont(name: "HelveticaNeue-Medium", size: 13)!
        static let myAccountNoTicketFont = UIFont(name: "HelveticaNeue", size: 13)!
    }
    
    struct Color {
        
        // Colors
        static let blue = UIColor(hex6: 0x4285F4)
        static let blueCorrectedForNavbar = UIColor(hex6: 0x519BF7) // Actually #4285F4
        static let yellow = UIColor(hex6: 0xFBBC05)
        static let orange = UIColor(hex6: 0xF5810E)
        static let red = UIColor(hex6: 0xEA4235)
        static let black = UIColor(hex6: 0x000000)
        static let lightBlack = UIColor(hex6: 0x404040)
        static let white = UIColor(hex6: 0xFFFFFF)
        static let offWhite = UIColor(hex6: 0xF7F7F7)
        static let gray = UIColor(hex6: 0x808080)
        static let lightGray = UIColor(hex6: 0xD6D6D6)
        static let superLightGray = UIColor(hex6: 0xE1E1E1)
        
        // Default theme
        static let primary = blue
        static let secondary = orange
        static let background = superLightGray
        
        // Component defaults
        static let textFieldBackground = offWhite
        static let textFieldPanelBorder = lightGray
        
        static let tabBarViewBackground = lightGray
        static let tabBarBackground = white
        
        static let textNormal = gray
        static let textUnselected = UIColor(hex6: 0xB9B9B9)
        static let textSelected = secondary
        
        static let pageControlUnselected = UIColor(hex6: 0xABABAB)
        static let pageControlSelected = UIColor(hex6: 0xEFA60A)
        
        static let buttonEnableBackground = secondary
        static let buttonEnableBorder = UIColor(hex6: 0xF9AD65)
        static let buttonDisableBackground = lightGray
        static let buttonDisableBorder = offWhite
        
        static let profileDefaultBackground = lightGray
        
        static let shadow = gray
    }

    
    struct CardView {
        
        static let cornerRadius: CGFloat = 5.0
        
        static let exploreCellCornerRadius: CGFloat = 16.0
        static let exploreCellShadowOffset = CGSize(width: 0.0, height: 1.0)
        static let exploreCellShadowRadius: CGFloat = 2.5
        static let exploreCellShadowOpacity: Float = 0.6
        
        static func setup(view: UIView) {
            view.layer.masksToBounds = true
            view.layer.cornerRadius = cornerRadius
        }
    }
    
    // MARK: Helper methods
    
    /**
     Setup the default appearance of UIKit components globally (called once from app delegate)
     */
    static func initialiseGlobalAppearance() {
        // Set status bar light content
        UIApplication.shared.statusBarStyle = .lightContent
        
        // Tab bar colour
        UITabBar.appearance().barTintColor = Color.tabBarBackground
        UITabBar.appearance().tintColor = Color.secondary
        UITabBar.appearance().isTranslucent = false
        // Tab bar remove shadow (both lines required)
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        
        // Tab bar selection image (white bottom border)
        let tabBarHeight: CGFloat = 49.0
        let borderHeight: CGFloat = 3.5
        let tabIndicator = Color.white.bottomBorderImage(height: tabBarHeight, borderHeight: borderHeight)
        UITabBar.appearance().selectionIndicatorImage = tabIndicator
        
        // Tab bar text
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Color.textUnselected], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: Color.textSelected], for: .selected)
        UITabBarItem.appearance().titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -borderHeight+1)
        
        // Navigation bar
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = Color.blue
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: Style.Font.navigationTitleCustomFont, NSForegroundColorAttributeName: Style.Color.white]
        UINavigationBar.appearance().tintColor = UIColor.white
        
        UIToolbar.appearance().barTintColor = Color.blue
        UIToolbar.appearance().tintColor = UIColor.white
        
        CheckboxButton.appearance().containerColor = Color.lightGray
        CheckboxButton.appearance().checkColor = Color.secondary
        CheckboxButton.appearance().checkLineWidth = 3.0
        CheckboxButton.appearance().circular = true
        
        SVProgressHUD.setBackgroundColor(Color.black.withAlphaComponent(0.8))
        SVProgressHUD.setForegroundColor(Color.white)
        SVProgressHUD.setFont(Font.progressHUDFont)
        SVProgressHUD.setRingThickness(7.0)
        SVProgressHUD.setMinimumSize(CGSize(width: 120, height: 120))
    }

    
    /**
     Apply the global style to a tabBarItem
     - parameter tabBarItem: The item to apply the global style
     */
    static func applyStyleToTabBarItem(tabBarItem: UITabBarItem) {
        if let selectedImage = tabBarItem.selectedImage {
            tabBarItem.image = selectedImage.imageWithAlpha(alpha: 0.84).withRenderingMode(.alwaysOriginal)
        }
    }
}
