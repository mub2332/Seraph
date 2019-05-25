//
//  ContactsListVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 3/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ContactsListVC: UITableViewController, UISearchResultsUpdating, DatabaseListener, CNContactPickerDelegate {
    
    let bgColorView = UIView()
    
    var filteredContacts = [Contact]()
    var allContacts = [Contact]()
    
    private let contactPicker = CNContactPickerViewController()
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgColorView.backgroundColor = UIColor(red: 85/255, green: 186/255, blue: 85/255, alpha: 1)
        
        filteredContacts = allContacts
        
        // Setup search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search contacts"
        searchController.searchBar.tintColor = UIColor(red: 85/255, green: 186/255, blue: 85/255, alpha: 1)
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue): UIColor.red], for: .normal)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        definesPresentationContext = true
        
        // Setup database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController        
    }
    
    // MARK:- Search results controller
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(),
            searchText.count > 0 {
            filteredContacts = allContacts.filter({(contact: Contact) -> Bool in
                return (contact.name.lowercased().starts(with: searchText))
            })
        } else {
            filteredContacts = allContacts
        }
        
        filteredContacts.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
        tableView.reloadData()
    }
    
    // MARK:- Table view delegate
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let contact = filteredContacts[indexPath.row]
        
        cell.textLabel?.text = contact.name
        cell.textLabel?.textColor = UIColor.white
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    // MARK:- Table view cell trailing swipe action
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Set action to perform when swiped
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, handler) in
            self.deleteContact(contact: self.filteredContacts[indexPath.row])
        })
        
        deleteAction.backgroundColor = .red
        let config = UISwipeActionsConfiguration(actions: [deleteAction])
        return config
    }
    
    func deleteContact(contact: Contact) {
        let _ = databaseController?.deleteContact(contact: contact)
    }
    
    // MARK:- Database listener
    
    var listenerType: ListenerType = ListenerType.contacts
    
    func onContactsListChange(change: DatabaseChange, contacts: [Contact]) {
        allContacts = contacts
        filteredContacts = contacts
        filteredContacts.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        filteredContacts.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    @IBAction func addContact(_ sender: Any) {
        performSegue(withIdentifier: "AddContact", sender: "")
    }
    
    @IBAction func deleteAllContacts(_ sender: Any) {
        self.displayMessage(title: "Confirm", message: "Are you sure you want to delete all contacts?", onCompletion: deleteContacts)
    }
    
    func deleteContacts() {
        self.databaseController?.deleteAllContacts()
        return
    }
    
    @IBAction func importContacts(_ sender: Any) {
        contactPicker.delegate = self
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for contact in contacts {
            let name = contact.givenName + " " + contact.familyName
            
            if allContacts.contains(where: { (contact) -> Bool in
                return contact.name.lowercased() == name.lowercased()
            }) {
                picker.displayMessage(title: "Oops!", message: "This contact is already in your contacts list", onCompletion: doNothing)
                return
            }
            
            self.databaseController?.addContact(name: contact.givenName + " " + contact.familyName,
                                                phone: ((contact.phoneNumbers[0].value as! CNPhoneNumber).value(forKey: "digits") as? String)!)
        }
    }
    
    func doNothing() {
        return
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditContact" {
            let controller = segue.destination as! ContactDetailVC
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.contactToEdit = filteredContacts[indexPath.row]
            }
        }
        
        if segue.identifier == "AddContact" {
            let controller = segue.destination as! ContactDetailVC
            controller.allContacts = allContacts
        }
    }
    
}
