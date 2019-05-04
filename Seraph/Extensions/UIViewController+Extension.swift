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

