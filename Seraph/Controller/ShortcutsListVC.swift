//
//  ShortcutsListVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 25/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit
import Intents
import IntentsUI

class ShortcutsListVC: UITableViewController, UIGestureRecognizerDelegate {
    
    // Hardcoded shortcuts as I don't want user to be able to make shortcuts
    // for just about any action as that wouldn't be feasible
    let shortcuts = [
        "Send SOS",
        "Emergency Call",
        "Import Contacts",
        "Add Contact",
        "Select Contact",
        "Delete Contacts",
        "Edit SOS",
        "Edit Shortcuts"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return shortcuts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.rowHeight = 60
        tableView.estimatedRowHeight = 60
        let shortcut = shortcuts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShortcutCell")! as UITableViewCell
        cell.textLabel?.text = shortcut
        cell.textLabel?.textColor = UIColor.lightGray
        
        let button = INUIAddVoiceShortcutButton(style: .blackOutline)
        // Attach button to the appropriate shortcut
        switch shortcut {
        case "Send SOS":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.SendSOS",
                                       withTitle: "Send SOS"), for: button)
            break
        case "Emergency Call":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.MakeEmergencyCall",
                                       withTitle: "Emergency Call"), for: button)
            break
        case "Import Contacts":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.ImportContacts",
                                       withTitle: "Import Contacts"), for: button)
            break
        case "Add Contact":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.AddContact", withTitle: "Add Contact"), for: button)
            break
        case "Select Contact":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.SelectContact", withTitle: "Select Contact"), for: button)
            break
        case "Delete Contacts":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.DeleteAllContacts", withTitle: "Delete Contacts"), for: button)
            break
        case "Edit SOS":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.EditSOSMessage", withTitle: "Edit SOS"), for: button)
            break
        case "Edit Shortcuts":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.EditShortcuts", withTitle: "Edit Shortcuts"), for: button)
            break
        default:
            break
        }
        
        button.delegate = self
        button.translatesAutoresizingMaskIntoConstraints = false
        // Add button to cell
        cell.addSubview(button)
        cell.rightAnchor.constraint(equalTo: button.rightAnchor, constant: 8).isActive = true
        cell.centerYAnchor.constraint(equalTo: button.centerYAnchor, constant: 0).isActive = true
        
        return cell
    }
    // create activity with specified arguments
    func createActivity(withIdentifier identifier: String, withTitle title: String) -> NSUserActivity {
        let activity = NSUserActivity(activityType: identifier)
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: identifier)
        activity.title = title
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        return activity
    }
    // assign shortcut to siri button
    func setShortcut(_ activity: NSUserActivity, for button: INUIAddVoiceShortcutButton) {
        button.shortcut = INShortcut(userActivity: activity)
    }

}

// MARK:- Siri Shortcut delegates
// Handles presenting the appropriate Siri Shortcut view

extension ShortcutsListVC: INUIAddVoiceShortcutButtonDelegate {
    func present(_ addVoiceShortcutViewController: INUIAddVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        addVoiceShortcutViewController.delegate = self
        addVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(addVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    func present(_ editVoiceShortcutViewController: INUIEditVoiceShortcutViewController, for addVoiceShortcutButton: INUIAddVoiceShortcutButton) {
        editVoiceShortcutViewController.delegate = self
        editVoiceShortcutViewController.modalPresentationStyle = .formSheet
        present(editVoiceShortcutViewController, animated: true, completion: nil)
    }
    
    
}

extension ShortcutsListVC: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ShortcutsListVC: INUIEditVoiceShortcutViewControllerDelegate {
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didUpdate voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewController(_ controller: INUIEditVoiceShortcutViewController, didDeleteVoiceShortcutWithIdentifier deletedVoiceShortcutIdentifier: UUID) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func editVoiceShortcutViewControllerDidCancel(_ controller: INUIEditVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

