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
    
    
    
}
