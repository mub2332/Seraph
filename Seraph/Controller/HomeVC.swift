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
        
        if let location = currentLocation {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                var placemark: CLPlacemark!
                placemark = placemarks?[0]
                
                // Location name
                if let locationName = placemark.name {
                    self.address += locationName + ", "
                }
                
                // Street address
                if let street = placemark.thoroughfare {
                    self.address += street + ", "
                }
                
                // City
                if let city = placemark.locality {
                    self.address += city + ", "
                }
                
                if let state = placemark.administrativeArea {
                    self.address += state + " "
                }
                
                // Zip code
                if let zip = placemark.postalCode {
                    self.address += zip + ", "
                }
                
                // Country
                if let country = placemark.country {
                    self.address += country
                }
                
                let messageVC = MFMessageComposeViewController()
                
                messageVC.body = "Help me at " + self.address
                messageVC.recipients = self.phoneNumbers
                messageVC.messageComposeDelegate = self
                
                self.present(messageVC, animated: true, completion: nil)
            })
        }
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
