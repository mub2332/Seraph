//
//  FirebaseController.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject, DatabaseProtocol {
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var contactsRef: CollectionReference?
    
    var contactsList: [Contact]
    
    override init() {
        FirebaseApp.configure()
        
        authController = Auth.auth()
        database = Firestore.firestore()
        contactsList = [Contact]()
        
        super.init()
        
        authController.signInAnonymously() {(authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
            
            self.setupListeners()
        }
    }
    
    func setupListeners() {
        contactsRef = database.collection("contacts")
        contactsRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                print("Error fetching documents: \(error)")
                return
            }
            
            self.parseContactsSnapshot(snapshot: querySnapshot!)
        }
    }
    
    func parseContactsSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            let documentRef = change.document.documentID
            let name = change.document.data()["name"] as! String
            let phone = change.document.data()["phone"] as! String
            
            if change.type == .added {
                let newContact = Contact(name: name, phone: phone, id: documentRef)
                contactsList.append(newContact)
            }
            
            if change.type == .modified {
                let index = getContactIndexByID(reference: documentRef)!
                contactsList[index].name = name
                contactsList[index].phone = phone
            }
            
            if change.type == .removed {
                if let index = getContactIndexByID(reference: documentRef) {
                    contactsList.remove(at: index)
                }
            }
            
            listeners.invoke { (listener) in
                if listener.listenerType == .contacts || listener.listenerType == .all {
                    listener.onContactsListChange(change: .update, contacts: contactsList)
                }
            }
        }
    }
    
    func getContactIndexByID(reference: String) -> Int? {
        for contact in contactsList {
            if(contact.id == reference) {
                return contactsList.firstIndex(of: contact)
            }
        }
        
        return nil
    }
    
    func getContactByID(reference: String) -> Contact? {
        for contact in contactsList {
            if(contact.id == reference) {
                return contact
            }
        }
        
        return nil
    }
    
    func addContact(name: String, phone: String) -> Contact {
        let id = contactsRef?.addDocument(data: [
            "name": name,
            "phone": phone
        ])
        let contact = Contact(name: name, phone: phone, id: id!.documentID)
        
        return contact
    }
    
    func deleteContact(contact: Contact) {
        contactsRef?.document(contact.id).delete()
    }
    
    func editContact(contact: Contact, name: String, phone: String) {
        contactsRef?.document(contact.id).updateData([
            "name": name,
            "phone": phone
        ])
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.contacts || listener.listenerType == ListenerType.all {
            listener.onContactsListChange(change: .update, contacts: contactsList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
