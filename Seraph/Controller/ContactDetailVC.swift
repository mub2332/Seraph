//
//  ContactDetailVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class ContactDetailVC : UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var contactToEdit: Contact?
    var allContacts = [Contact]()
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
        
        if let contactToEdit = contactToEdit {
            title = "Edit Contact"
            nameTextField.text = contactToEdit.name
            phoneTextField.text = contactToEdit.phone
        } else {
            title = "Add Contact"
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        navigationController?.popViewController(animated: true)
        return
    }
    
    @IBAction func saveContact(_ sender: Any) {
        if nameTextField.text == "" || phoneTextField.text == "" {
            self.displayMessage(title: "All inputs must be filled", message: "Please enter both name and a valid phone number", shouldPopViewControllerOnCompletion: false)
            return
        }
        
        if !PhoneValidator.isPhone(phoneTextField.text!) {
            self.displayMessage(title: "Invalid phone number entered", message: "Please enter a valid Australian phone number", shouldPopViewControllerOnCompletion: false)
            return
        }
        
        let name = nameTextField.text!
        let phone = phoneTextField.text!
        
        if allContacts.contains(where: {contact in
            return contact.name == name
        }) {
            self.displayMessage(title: "Oops!", message: "A contact with that name already exists. Please pick a different name", shouldPopViewControllerOnCompletion: false)
            return
        }
        
        if let contact = contactToEdit {
            let _ = databaseController?.editContact(contact: contact, name: name, phone: phone)
            self.displayMessage(title: "Success!", message: "Contact has been updated!", shouldPopViewControllerOnCompletion: true)
        } else {
            let _ = databaseController?.addContact(name: name, phone: phone)
            self.displayMessage(title: "Success!", message: "Contact has been added!", shouldPopViewControllerOnCompletion: true)
        }
    }
    
    @IBAction func clearAll(_ sender: Any) {
        nameTextField.text = ""
        phoneTextField.text = ""
    }
}
