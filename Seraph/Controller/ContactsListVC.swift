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
    
    struct Section {
        let letter: String
        let contacts: [Contact]
    }
    
    var filteredContacts = [Contact]()
    var allContacts = [Contact]()
    var sections = [Section]()
    
    private let contactPicker = CNContactPickerViewController()
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = false
        bgColorView.backgroundColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
        
        tableView.sectionIndexColor = UIColor.lightGray
        filteredContacts = allContacts
        sectionify()
        
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
    
    func sectionify() {
        // group the array to ["N": ["Nancy"], "S": ["Sue", "Sam"], "J": ["John", "James", "Jenna"], "E": ["Eric"]]
        let groupedDictionary = Dictionary(grouping: filteredContacts, by: {String($0.name.lowercased().prefix(1))})
        // get the keys and sort them
        let keys = groupedDictionary.keys.sorted()
        // map the sorted keys to a struct
        sections = keys.map{ Section(letter: $0, contacts: groupedDictionary[$0]!.sorted(by: { (first, second) -> Bool in
            return first.name.lowercased() < second.name.lowercased()
        })) }
        self.tableView.reloadData()
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
        sectionify()
    }
    
    // MARK:- Table view delegate
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        let label = UILabel(frame: CGRect(x: 15, y: 0, width: tableView.frame.size.width, height: 30))
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.text = self.sections[section].letter.uppercased()
        label.textColor = UIColor.white
        view.addSubview(label)
        view.backgroundColor = UIColor(red: 11/255, green: 11/255, blue: 11/255, alpha: 1)
        return view
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sections.map { $0.letter.uppercased() }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].letter.uppercased()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return filteredContacts.count
        return sections[section].contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
//        let contact = filteredContacts[indexPath.row]
        
        let section = sections[indexPath.section]
        let contact = section.contacts[indexPath.row]
        
        cell.textLabel?.text = contact.name
        cell.textLabel?.textColor = UIColor.lightGray
        cell.selectedBackgroundView = bgColorView
        return cell
    }
    
    // MARK:- Table view cell trailing swipe action
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Set action to perform when swiped
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, handler) in
            self.deleteContact(contact: self.sections[indexPath.section].contacts[indexPath.row])
        })
        
        deleteAction.image = UIImage(named: "delete")
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
        sectionify()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
        tabBarController?.tabBar.isHidden = false

        filteredContacts.sort(by: { $0.name.lowercased() < $1.name.lowercased() })
        sectionify()
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
    // Display contact picker interface to get contacts from phonebook
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        for contact in contacts {
            let name = contact.givenName + " " + contact.familyName
            
            if allContacts.contains(where: { (contact) -> Bool in
                return contact.name.lowercased() == name.lowercased()
            }) {
                picker.displayMessage(title: "Oops!", message: "This contact is already in your contacts list", onCompletion: doNothing)
                return
            }
            
            self.databaseController?.addContact(name: contact.givenName,
                                                phone: ((contact.phoneNumbers[0].value as! CNPhoneNumber).value(forKey: "digits") as? String)!)
        }
    }
    // convenience method to pass as nil handler to alert function
    func doNothing() {
        return
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditContact" {
            let controller = segue.destination as! ContactDetailVC
            // pass contact object to edit screen
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.contactToEdit = sections[indexPath.section].contacts[indexPath.row]
            }
        }
        
        if segue.identifier == "AddContact" {
            let controller = segue.destination as! ContactDetailVC
            controller.allContacts = allContacts
        }
    }
    
}
