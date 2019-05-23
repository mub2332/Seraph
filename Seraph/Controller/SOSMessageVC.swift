//
//  SOSMessageVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 23/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class SOSMessageVC: UIViewController {
    
    @IBOutlet weak var messageTextField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        messageTextField.text = readStringData(forKey: "SOS Message")
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        messageTextField.text = readStringData(forKey: "SOS Message")
    }
    
    @IBAction func save(_ sender: Any) {
        writeData(forKey: "SOS Message", withValue: messageTextField.text)
        self.displayMessage(title: "Success!", message: "Message has been saved!", onCompletion: reset)
    }
    
    @IBAction func cancel(_ sender: Any) {
        reset()
    }
    
    @IBAction func clear(_ sender: Any) {
        messageTextField.text = ""
    }
    func reset() {
        tabBarController?.selectedIndex = 0
        return
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
