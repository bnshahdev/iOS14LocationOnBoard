//
//  ViewController.swift
//  iOS14LocationOnBoard
//
//  Created by MacBook on 29/08/20.
//

import UIKit
import CoreLocation
import Foundation


class ViewController: UIViewController {

    var locationManager:CLLocationManager? = CLLocationManager()
    
    @IBOutlet weak var lblLocationAccess: UILabel!
    @IBOutlet weak var lblPreciseLocationAccess: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.applicationBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        self.configureLocationManager()
    }
    
    private func configureLocationManager() {
      locationManager?.desiredAccuracy = kCLLocationAccuracyBest
      locationManager?.delegate = self
      locationManager?.activityType = .automotiveNavigation
      locationManager?.requestAlwaysAuthorization()
        
      updateStatus()
    }
    
    @objc func applicationBecomeActive(){
        
        updateStatus()
        
        //check for accuracy
        if let accuracyStatus = locationManager?.accuracyAuthorization {
            if(accuracyStatus == .reducedAccuracy) {
                promptUserForAccuracy()
            }
        }
      
    }
    
    @objc func openLocationSettings(){
      DispatchQueue.main.async {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
          }
          if UIApplication.shared.canOpenURL(settingsUrl) {
              UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
        }
      }
    }
    
    private func promptUserForAccuracy() {
        let alert = UIAlertController(title: "Why No to precise?", message: "Visit Settings and mark it ON", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Don't Agree", style: .default, handler: { (_) in }))
        alert.addAction(UIAlertAction(title: "Agree", style: .default, handler: { (_) in
            self.openLocationSettings()
        }))
        

        self.present(alert, animated: true, completion: nil)
    }
    
    func updateStatus() {
        if let status = locationManager?.authorizationStatus {
            lblLocationAccess.text = status.description
        }
        
        if let accuracyStatus = locationManager?.accuracyAuthorization {
            lblPreciseLocationAccess.text = accuracyStatus.description
        }
    }
    
}

extension ViewController {
    @IBAction func askTemporaryAccuracyFirst() {
        
        if let accuracyStatus = locationManager?.accuracyAuthorization {
            if(accuracyStatus == .reducedAccuracy) {
                locationManager?.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "AccuracyFeatureFirst", completion: { (error) in
                    print("error -> \(error.debugDescription)")
                })
            }
        }
        
        
    }
    
    @IBAction func askTemporaryAccuracySecond() {
        if let accuracyStatus = locationManager?.accuracyAuthorization {
            if(accuracyStatus == .reducedAccuracy) {
                locationManager?.requestTemporaryFullAccuracyAuthorization(withPurposeKey: "AccuracyFeatureSecond", completion: { (error) in
                    print("error -> \(error.debugDescription)")
                })
            }
        }
    }
}


extension ViewController : CLLocationManagerDelegate {
  public func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
    
  }
  public func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
    
  }
  
  public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

    // The locations parameter always contains at least one location and may contain more than one. Locations are always reported in the order in which they were determined, so the most recent location is always the last item in the array.
    // https://developer.apple.com/documentation/corelocation/getting_the_user_s_location/using_the_significant-change_location_service?language=objc

    if let location = locations.last {
        print("location received -> \(location)")
    }

    
  }
  
  
public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("didChangeAuthorization: \(status.description)")
        updateStatus()
    }
    
}
  


extension CLAuthorizationStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .denied: return "denied"
        case .restricted: return "restricted"
        case .notDetermined: return "notDetermined"
        case .authorizedAlways: return "AuthorizedAlways"
        case .authorizedWhenInUse: return "authorizedWhenInUse"
        default: return "unknown default"
        }
    }
}

extension CLAccuracyAuthorization: CustomStringConvertible {
    public var description: String {
        switch self {
        case .fullAccuracy: return "fullAccuracy"
        case .reducedAccuracy: return "reducedAccuracy"
       
        default: return "unknown default"
        }
    }
}
