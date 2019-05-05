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

class HomeVC : UIViewController, MFMessageComposeViewControllerDelegate, CLLocationManagerDelegate, DatabaseListener {
    
    var contactsList = [Contact]()
    var phoneNumbers = [String]()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var address = ""
    
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup database controller
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    @IBAction func sendSOS(_ sender: Any) {
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        locationManager.startUpdatingLocation()
        
        let messageVC = MFMessageComposeViewController()
        
        if let location = currentLocation {
            messageVC.body = "Help me at this location"
            messageVC.addAttachmentURL(locationVCardURLFromCoordinate(coordinate: location.coordinate)! as URL, withAlternateFilename: "vCard.loc.vcf")
        } else {
            self.displayMessage(title: "Oops!", message: "Location could not be found", shouldPopViewControllerOnCompletion: false)
            locationManager.stopUpdatingLocation()
            return
        }
        
        locationManager.stopUpdatingLocation()
        messageVC.recipients = self.phoneNumbers
        messageVC.messageComposeDelegate = self
        
        self.present(messageVC, animated: true, completion: nil)
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
        for contact in contactsList {
            phoneNumbers.append(contact.phone)
        }
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
