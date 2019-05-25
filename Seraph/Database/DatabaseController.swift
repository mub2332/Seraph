//
//  FirebaseController.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit
import CoreData

class DatabaseController: NSObject, DatabaseProtocol, NSFetchedResultsControllerDelegate {
    var listeners = MulticastDelegate<DatabaseListener>()
    var persistantContainer: NSPersistentContainer
    
    var allContactsFetchedResultsController: NSFetchedResultsController<Contact>?
    
    override init() {
        persistantContainer = NSPersistentContainer(name: "Seraph")
        persistantContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        super.init()
    }
    
    func saveContext() {
        if persistantContainer.viewContext.hasChanges {
            do {
                try persistantContainer.viewContext.save()
            } catch {
                fatalError("Failed to save data to Core Data: \(error)")
            }
        }
    }
    
    func addContact(name: String, phone: String) -> Contact {
        let contact = NSEntityDescription.insertNewObject(forEntityName: "Contact", into: persistantContainer.viewContext) as! Contact
        contact.name = name
        contact.phone = phone
        
        saveContext()
        return contact
    }
    
    func deleteContact(contact: Contact) {
        persistantContainer.viewContext.delete(contact)
        saveContext()
    }
    
    func editContact(contact: Contact, name: String, phone: String) {
        contact.name = name
        contact.phone = phone
        saveContext()
    }
    
    func deleteAllContacts() {
        let contacts = fetchAllContacts()
        for contact in contacts {
            persistantContainer.viewContext.delete(contact)
        }
        saveContext()
    }
    
    func fetchAllContacts() -> [Contact] {
        if allContactsFetchedResultsController == nil {
            let fetchRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
            let nameSortDescriptor = NSSortDescriptor(key: "name", ascending: true)
            fetchRequest.sortDescriptors = [nameSortDescriptor]
            allContactsFetchedResultsController =
                NSFetchedResultsController<Contact>(fetchRequest: fetchRequest,
                                                    managedObjectContext: persistantContainer.viewContext,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
            allContactsFetchedResultsController?.delegate = self
            do {
                try allContactsFetchedResultsController?.performFetch()
            } catch {
                print("Fetch Request failed: \(error)")
            }
        }
        
        var contacts = [Contact]()
        if allContactsFetchedResultsController?.fetchedObjects != nil {
            contacts = (allContactsFetchedResultsController?.fetchedObjects)!
        }
        
        return contacts
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.contacts || listener.listenerType == ListenerType.all {
            listener.onContactsListChange(change: .update, contacts: fetchAllContacts())
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
    
    func controllerDidChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == allContactsFetchedResultsController {
            listeners.invoke { (listener) in
                if listener.listenerType == ListenerType.contacts ||
                    listener.listenerType == ListenerType.all {
                    listener.onContactsListChange(change: .update, contacts: fetchAllContacts())
                }
            }
        }
    }
}
