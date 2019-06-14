//
//  UITabBarController+Extension.swift
//  Seraph
//
//  Created by Musa  Mahmud on 26/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

extension UITabBarController: UITabBarControllerDelegate  {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    // Set up cross dissolve animation on tab switch
    public func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        guard let fromView = selectedViewController?.view, let toView = viewController.view else {
            return false // Make sure you want this as false
        }
        
        if fromView != toView {
            UIView.transition(from: fromView, to: toView, duration: 0.3, options: [.transitionCrossDissolve], completion: nil)
        }
        
        return true
    }
}
