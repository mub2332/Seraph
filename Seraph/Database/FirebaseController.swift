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
            print(documentRef)
            
            if change.type == .added {
                print("New contact: \(change.document.data())")
                let newContact = Contact(name: name, phone: phone, id: documentRef)
                contactsList.append(newContact)
            }
            
            if change.type == .modified {
                print("Updated contact: \(change.document.data())")
                
            }
        }
    }
}
