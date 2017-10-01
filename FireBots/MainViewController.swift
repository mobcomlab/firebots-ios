//
//  MainViewController.swift
//  ParentsHero
//
//  Created by Admin on 10/6/2559 BE.
//  Copyright © 2559 Admin. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    private var viewController: UIViewController
    var chatroomID: String?
    
    var dynamicLinkURL: URL? {
        didSet {
//            if !currentViewController.isKind(of: SplashScreenViewController.self) {
//                if let url = dynamicLinkURL {
//                    let urlString = url.absoluteString
//                    if urlString.range(of: FBConstant.DynamicLink.ticket) != nil {
//                        swapToTabBarController(selectedIndex: 1)
//                    }
//                    if urlString.range(of: FBConstant.DynamicLink.activityDetail) != nil {
//                        swapToTabBarController(selectedIndex: 0)
//                    }
//                }
//            }
        }
    }
    
    init(viewController: UIViewController) {
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        assertionFailure()
        viewController = UIViewController()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(viewController)
        addSubview(subView: viewController.view, toView: view)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func didMessageReceive() {
        
    }
    
    func setViewController(newViewController: UIViewController) {
        
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        cycleFromViewController(oldViewController: viewController, toViewController: newViewController)
        viewController = newViewController
    }
    
    var currentViewController: UIViewController {
        return viewController
    }
    
    // MARK: - Private
    
    private func addSubview(subView: UIView, toView parentView: UIView) {
        parentView.addSubview(subView)
        
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|",
                                                                                 options: [], metrics: nil, views: viewBindingsDict))
    }
    
    private func cycleFromViewController(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        
        oldViewController.willMove(toParentViewController: nil)
        addChildViewController(newViewController)
        addSubview(subView: newViewController.view, toView: view)
        
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
            }, completion: { finished in
                oldViewController.view.removeFromSuperview()
                oldViewController.removeFromParentViewController()
                newViewController.didMove(toParentViewController: self)
        })
    }

}
