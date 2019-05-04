//
//  DatabaseProtocol.swift
//  2019S1 Lab 3
//
//  Created by Michael Wybrow on 22/3/19.
//  Copyright © 2019 Michael Wybrow. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case contacts
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
}

protocol DatabaseProtocol: AnyObject {
    func addContact(name: String, phone: String) -> Contact
    func deleteContact(contact: Contact)
    func editContact(contact: Contact, name: String, phone: String)
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
