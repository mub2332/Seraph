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

class ShortcutsListVC: UITableViewController {
    
    let shortcuts = [
        "Send SOS",
        "Import Contacts",
        "Add Contact",
        "Select Contact",
        "Delete All Contacts",
        "Edit SOS Message",
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
        
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = 60
        let shortcut = shortcuts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShortcutCell")! as UITableViewCell
        cell.textLabel?.text = shortcut
        cell.textLabel?.textColor = UIColor.white
        
        let button = INUIAddVoiceShortcutButton(style: .blackOutline)
        
        switch shortcut {
        case "Send SOS":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.SendSOS",
                                       withTitle: "Send SOS"), for: button)
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
        case "Delete All Contacts":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.DeleteAllContacts", withTitle: "Delete All Contacts"), for: button)
            break
        case "Edit SOS Message":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.EditSOSMessage", withTitle: "Edit SOS Message"), for: button)
            break
        case "Edit Shortcuts":
            setShortcut(createActivity(withIdentifier: "com.example.seraph.EditShortcuts", withTitle: "Edit Shortcuts"), for: button)
            break
        default:
            break
        }
        
        button.delegate = self
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        cell.addSubview(button)
        cell.rightAnchor.constraint(equalTo: button.rightAnchor).isActive = true
        cell.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        return cell
    }
    
    func createActivity(withIdentifier identifier: String, withTitle title: String) -> NSUserActivity {
        let activity = NSUserActivity(activityType: identifier)
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: identifier)
        activity.title = title
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    func setShortcut(_ activity: NSUserActivity, for button: INUIAddVoiceShortcutButton) {
        button.shortcut = INShortcut(userActivity: activity)
    }

}

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

