//
//  ContactsListVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 3/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit

class ContactsListVC: UITableViewController, UISearchResultsUpdating, DatabaseListener {
    
    var filteredContacts = [Contact]()
    var allContacts = [Contact]()
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredContacts = allContacts
        
        // Setup search controller
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search contacts"
        navigationItem.searchController = searchController
        
        definesPresentationContext = true
        
        // Setup database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text?.lowercased(),
            searchText.count > 0 {
            filteredContacts = allContacts.filter({(contact: Contact) -> Bool in
                return (contact.name.lowercased().contains(searchText))
            })
        } else {
            filteredContacts = allContacts
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let contact = filteredContacts[indexPath.row]
        
        cell.textLabel?.text = contact.name
        return cell
    }
    
    var listenerType: ListenerType = ListenerType.contacts
    
    func onContactsListChange(change: DatabaseChange, contacts: [Contact]) {
        allContacts = contacts
        filteredContacts = contacts
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
}
