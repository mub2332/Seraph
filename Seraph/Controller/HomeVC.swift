//
//  HomeVC.swift
//  Seraph
//
//  Created by Musa  Mahmud on 4/5/19.
//  Copyright © 2019 Mubtasim  Mahmud. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation
import Intents
import IntentsUI

class HomeVC : UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate, DatabaseListener {
    
    @IBOutlet weak var sosButton: RedBorderButton!
    
    var contactsList = [Contact]()
    var phoneNumbers = [String]()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var address = ""
    var timer: Timer?
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let button = INUIAddVoiceShortcutButton(style: .blackOutline)
        button.shortcut = INShortcut(userActivity: sendSOSActivity())
        button.delegate = self
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(button)
        view.centerXAnchor.constraint(equalTo: button.centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: button.centerYAnchor).isActive = true
        
        // Setup database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    func sendSOSActivity() -> NSUserActivity {
        let activity = NSUserActivity(activityType: "com.example.seraph.SendSOS")
        activity.persistentIdentifier = NSUserActivityPersistentIdentifier(stringLiteral: "com.example.seraph.SendSOS")
        activity.title = "Send SOS"
        activity.isEligibleForSearch = true
        activity.isEligibleForPrediction = true
        return activity
    }
    
    @IBAction func sendSOS(_ sender: Any) {
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(getLocationAndSendMessage), userInfo: nil, repeats: true)
    }
    
    @objc func getLocationAndSendMessage() {
        let messageVC = MFMessageComposeViewController()

        if let location = currentLocation {
            timer?.invalidate()
            let spinner = showLoader(view: self.view)
            let message = readStringData(forKey: "SOS Message")
            if message == "" {
                messageVC.body = "Help me at this location"
            } else {
                messageVC.body = message
            }
            
            messageVC.addAttachmentURL(locationVCardURLFromCoordinate(coordinate: location.coordinate)! as URL, withAlternateFilename: "vCard.loc.vcf")
            locationManager.stopUpdatingLocation()
            messageVC.recipients = self.phoneNumbers
            messageVC.messageComposeDelegate = self
            
            self.present(messageVC, animated: true, completion: spinner.dismissLoader)
        }
        
    }
    
    func showLoader(view: UIView) -> UIActivityIndicatorView {
        //Customize as per your need
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 40, height:40))
        spinner.backgroundColor = UIColor(red: 33/255, green: 33/255, blue: 35/255, alpha: 1)
        spinner.layer.cornerRadius = 3.0
        spinner.clipsToBounds = true
        spinner.hidesWhenStopped = true
        spinner.style = UIActivityIndicatorView.Style.white;
        spinner.center.x = view.center.x
        spinner.center.y = view.center.y + 100
        self.view.addSubview(spinner)
        spinner.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        return spinner
    }
    
    func locationVCardURLFromCoordinate(coordinate: CLLocationCoordinate2D) -> NSURL?
    {
        guard let cachesPathString = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else {
            print("Error: couldn't find the caches directory.")
            return nil
        }
        
        guard CLLocationCoordinate2DIsValid(coordinate) else {
            print("Error: the supplied coordinate, \(coordinate), is not valid.")
            return nil
        }
        
        let vCardString = [
            "BEGIN:VCARD",
            "VERSION:3.0",
            "N:;Shared Location;;;",
            "FN:Shared Location",
            "item1.URL;type=pref:http://maps.apple.com/?ll=\(coordinate.latitude),\(coordinate.longitude)",
            "item1.X-ABLabel:map url",
            "END:VCARD"
            ].joined(separator: "\n")
        
        let vCardFilePath = (cachesPathString as NSString).appendingPathComponent("vCard.loc.vcf")
        
        do {
            try vCardString.write(toFile: vCardFilePath, atomically: true, encoding: String.Encoding.utf8)
        }
        catch let error {
            print("Error, \(error), saving vCard: \(vCardString) to file path: \(vCardFilePath).")
        }
        
        return NSURL(fileURLWithPath: vCardFilePath)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last!
        currentLocation = location
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
            dismiss(animated: true, completion: nil)
        case .failed:
            print("Message failed")
            dismiss(animated: true, completion: nil)
        case .sent:
            print("Message was sent")
            dismiss(animated: true, completion: nil)
        default:
            break
        }
    }
    
    // MARK:- Database listener
    
    var listenerType: ListenerType = ListenerType.contacts
    
    func onContactsListChange(change: DatabaseChange, contacts: [Contact]) {
        contactsList = contacts
        phoneNumbers = []
        for contact in contactsList {
            phoneNumbers.append(contact.phone)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        locationManager.startUpdatingLocation()
        databaseController?.addListener(listener: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        databaseController?.removeListener(listener: self)
    }
    
}

extension HomeVC: INUIAddVoiceShortcutButtonDelegate {
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

extension HomeVC: INUIAddVoiceShortcutViewControllerDelegate {
    func addVoiceShortcutViewController(_ controller: INUIAddVoiceShortcutViewController, didFinishWith voiceShortcut: INVoiceShortcut?, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func addVoiceShortcutViewControllerDidCancel(_ controller: INUIAddVoiceShortcutViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}

extension HomeVC: INUIEditVoiceShortcutViewControllerDelegate {
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
