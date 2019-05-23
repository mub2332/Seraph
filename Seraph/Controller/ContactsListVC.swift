//
//  ContactsListVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 3/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class ContactsListVC: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    let bgColorView = UIView()
    
    var filteredContacts = [Contact]()
    var allContacts = [Contact]()
    
    var contactsDictionary = [String:[String]]()
    var contactSectionTitles = [String]()
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bgColorView.backgroundColor = UIColor(red: 85/255, green: 186/255, blue: 85/255, alpha: 1)
        
        filteredContacts = allContacts
        sectionizeContacts()
        
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
    
    func sectionizeContacts() {
        contactsDictionary.removeAll()
        contactSectionTitles.removeAll()
        
        for contact in filteredContacts {
            let contactKey = String(contact.name.prefix(1))
            if var contactValues = contactsDictionary[contactKey] {
                contactValues.append(contact.name)
                contactsDictionary[contactKey] = contactValues
            } else {
                contactsDictionary[contactKey] = [contact.name]
            }
        }
        
        contactSectionTitles = [String](contactsDictionary.keys)
        contactSectionTitles = contactSectionTitles.sorted(by: { $0 < $1 })
    }
    
    // MARK:- Search results controller
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(),
            searchText.count > 0 {
            filteredContacts = allContacts.filter({(contact: Contact) -> Bool in
                return (contact.name.lowercased().contains(searchText))
            })
        } else {
            filteredContacts = allContacts
        }
        
        filteredContacts.sort(by: {$0.name.lowercased() < $1.name.lowercased()})
        sectionizeContacts()
        tableView.reloadData()
    }
    
    // MARK:- Table view delegate
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return contactSectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactSectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contactKey = contactSectionTitles[section]
        
        if let contactValues = contactsDictionary[contactKey] {
            return contactValues.count
        }
        
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)

        let contactKey = contactSectionTitles[indexPath.section]
        if let contactValues = contactsDictionary[contactKey] {
            cell.textLabel?.text = contactValues[indexPath.row]
            cell.textLabel?.textColor = UIColor.white
            cell.selectedBackgroundView = bgColorView
        }
        
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
        sectionizeContacts()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        
        filteredContacts.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
        sectionizeContacts()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
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
