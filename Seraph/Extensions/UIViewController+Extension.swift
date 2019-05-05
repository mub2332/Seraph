//
//  UIViewController+Extension.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func displayMessage(title: String, message: String, shouldPopViewControllerOnCompletion: Bool) {
        // display alert with the specified title and message
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        let subview = (alert.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.backgroundColor = UIColor(red: 35/255, green: 35/255, blue: 35/255, alpha: 1)
        alert.setValue(NSAttributedString(string: title, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),NSAttributedString.Key.foregroundColor : UIColor.white]), forKey: "attributedTitle")
        alert.setValue(NSAttributedString(string: message, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 14),NSAttributedString.Key.foregroundColor : UIColor.lightGray]), forKey: "attributedMessage")
        alert.view.tintColor = UIColor(red: 85/255, green: 186/255, blue: 85/255, alpha: 1)
        // pop current view controller on dismissing alert message
        if shouldPopViewControllerOnCompletion {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

