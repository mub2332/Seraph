//
//  SOSMessageVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 23/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class SOSMessageVC: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var messageHeader: UILabel!
    @IBOutlet weak var messageTextField: UITextView!
    @IBOutlet weak var clearButton: OrangeBorderButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        messageHeader.textColor = UIColor.lightGray
        messageTextField.textColor = UIColor.lightGray
        messageTextField.contentInset = UIEdgeInsets(top: 8, left: 5, bottom: 8, right: 5)
        messageTextField.text = readStringData(forKey: "SOS Message")
        
        let downwardSwipe = UISwipeGestureRecognizer(target: self, action: "tapView:")
        downwardSwipe.delegate = self
        downwardSwipe.cancelsTouchesInView = false
        downwardSwipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(downwardSwipe)
        messageTextField.addGestureRecognizer(downwardSwipe)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageTextField.text = readStringData(forKey: "SOS Message")
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func handleKeyboardNotification(_ notification: Notification) {
        
        if let userInfo = notification.userInfo {
            
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            bottomConstraint?.constant = isKeyboardShowing ? keyboardFrame!.height - 32 : 32
            
            UIView.animate(withDuration: 0.5, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
        
    }
    
    @IBAction func save(_ sender: Any) {
        writeData(forKey: "SOS Message", withValue: messageTextField.text)
        self.displayMessage(title: "Success!", message: "Message has been saved!", onCompletion: undoEdit)
    }
    
    @IBAction func clear(_ sender: Any) {
        messageTextField.text = ""
    }
    
    @IBAction func undo(_ sender: Any) {
        undoEdit()
    }
    
    func undoEdit() {
        messageTextField.text = readStringData(forKey: "SOS Message")
    }
    
    @IBAction func tapView(_ sender: Any) {
        hideKeyboard()
    }
    
    func hideKeyboard() {
        self.view.endEditing(true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
