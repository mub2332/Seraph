//
//  ContactDetailVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class ContactDetailVC : UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    var contactToEdit: Contact?
    var allContacts = [Contact]()
    // API stuff
    let API_KEY = "360584e4d1daf51d07915c2f3ddd2984"
    var url = "http://apilayer.net/api/validate?access_key="
    
    struct Phone: Decodable {
        let valid: Bool
    }
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBarController?.tabBar.isHidden = true
        
        url += API_KEY + "&number="
        // downward swipe to dismiss keyboard
        let downwardSwipe = UISwipeGestureRecognizer(target: self, action: "tapView:")
        downwardSwipe.delegate = self
        downwardSwipe.cancelsTouchesInView = false
        downwardSwipe.direction = UISwipeGestureRecognizer.Direction.down
        self.view.addGestureRecognizer(downwardSwipe)
        
        nameTextField.delegate = self
        phoneTextField.delegate = self
        nameTextField.tag = 100
        phoneTextField.tag = 101
        // Set up text field appearance
        nameTextField.setLeftPaddingPoints(10)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Enter name",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        phoneTextField.setLeftPaddingPoints(10)
        phoneTextField.attributedPlaceholder = NSAttributedString(string: "Enter phone number",
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        // Setup database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        // Setup view according to segue information
        if let contactToEdit = contactToEdit {
            title = "Edit Contact"
            nameTextField.text = contactToEdit.name
            phoneTextField.text = contactToEdit.phone
            doneButton.isEnabled = true
        } else {
            title = "Add Contact"
            doneButton.isEnabled = false
        }
    }
    // pass control to next text field in hierarchy
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    // enable done button when both inputs are filled in
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string) as NSString
        
        if nameTextField.text!.count > 0 && phoneTextField.text!.count > 0 {
            doneButton.isEnabled = newText.length > 0
        }
        
        return true
    }
    
    @IBAction func nameChanged(_ sender: Any) {
        checkIfNameAndPhoneProvided()
    }
    
    @IBAction func phoneChanged(_ sender: Any) {
        checkIfNameAndPhoneProvided()
    }
    // only enable done button if both inputs provided
    func checkIfNameAndPhoneProvided() {
        if nameTextField.text!.isEmpty || phoneTextField.text!.isEmpty {
            doneButton.isEnabled = false
        } else {
            doneButton.isEnabled = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameTextField.becomeFirstResponder()
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        return
    }
    
    @IBAction func saveContact(_ sender: Any) {
        nameTextField.text = nameTextField.text?.trimTrailingWhitespace()
        phoneTextField.text = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        // check if both inputs are filled
        if nameTextField.text == "" || phoneTextField.text == "" {
            self.displayMessage(title: "All inputs must be filled", message: "Please enter both name and a valid phone number", onCompletion: doNothing)
            return
        }
        
        let name = nameTextField.text!
        let phone = phoneTextField.text!
        
        if self.allContacts.contains(where: {contact in
            return contact.name.lowercased() == name.lowercased()
        }) {
            self.displayMessage(title: "Oops!", message: "A contact with that name already exists. Please pick a different name", onCompletion: self.doNothing)
            return
        }
        // For some reason API only handles international format
        // Using regex for local format
        if phone.starts(with: "+") {
            var request = URLRequest(url: URL(string: url + phoneTextField.text!)!)
            request.httpMethod = "GET"
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                do {
                    let phoneObject = try JSONDecoder().decode(Phone.self, from: data!)
                    
                    DispatchQueue.main.async {
                        // Display error message
                        if !phoneObject.valid {
                            self.displayMessage(title: "Invalid phone number entered", message: "Please enter a valid phone number", onCompletion: self.doNothing)
                            return
                        }
                        // Save contact
                        if let contact = self.contactToEdit {
                            let _ = self.databaseController?.editContact(contact: contact, name: name, phone: phone)
                            self.displayMessage(title: "Success!", message: "Contact has been updated!",
                                                onCompletion: self.popViewController)
                        } else {
                            let _ = self.databaseController?.addContact(name: name, phone: phone)
                            self.displayMessage(title: "Success!", message: "Contact has been added!",
                                                onCompletion: self.popViewController)
                        }
                    }
                    
                } catch let error as NSError {
                    print(error.localizedDescription)
                    // Display message if service didn't run
                    DispatchQueue.main.async {
                        self.displayMessage(title: "Oops!", message: "Phone number validation didn't work", onCompletion: self.doNothing)
                        return
                    }
                    
                }
                
                }.resume()
        } else {
            // Error if invalid number
            if !PhoneValidator.isPhone(phoneTextField.text!) {
                self.displayMessage(title: "Invalid phone number entered", message: "Please enter a valid Australian phone number", onCompletion: doNothing)
                return
            }
            // Save contact
            if let contact = self.contactToEdit {
                let _ = self.databaseController?.editContact(contact: contact, name: name, phone: phone)
                self.displayMessage(title: "Success!", message: "Contact has been updated!",
                                    onCompletion: self.popViewController)
            } else {
                let _ = self.databaseController?.addContact(name: name, phone: phone)
                self.displayMessage(title: "Success!", message: "Contact has been added!",
                                    onCompletion: self.popViewController)
            }
        }
        
    }
    
    func doNothing() {
        return
    }
    
    func popViewController() {
        navigationController?.popViewController(animated: true)
        return
    }
    
    @IBAction func clearAll(_ sender: Any) {
        nameTextField.text = ""
        phoneTextField.text = ""
        doneButton.isEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    @IBAction func tapView(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
}
