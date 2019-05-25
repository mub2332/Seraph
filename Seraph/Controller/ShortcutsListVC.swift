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
        "Import Contacts"
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
            setShortcut(sendSOSActivity(), for: button)
            break
        case "Import Contacts":
            setShortcut(importContactsActivity(), for: button)
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
    
    func sendSOSActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: "com.example.seraph.SendSOS")
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: "com.example.seraph.SendSOS")
        activity.title = "Send SOS"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    func importContactsActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: "com.example.seraph.ImportContacts")
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: "com.example.seraph.ImportContacts")
        activity.title = "Import Contacts"
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

