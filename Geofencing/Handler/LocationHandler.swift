//
//  LocationHandler.swift
//  Covid19Awarness
//
//  Created by Fahath Rajak on 08/06/20.
//  Copyright © 2020 Fahath. All rights reserved.
//

import UIKit
import CoreLocation

class LocationHandler: NSObject {
    typealias completion = () -> ()
    var didFinishAuthorized:((Bool?)->())? = nil
    var regionCompletion:((CLCircularRegion?, RegionMonitor)->())? = nil
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        UNUserNotificationCenter.current()
          .requestAuthorization(options: options) { success, error in
            if let error = error {
              print("Error: \(error)")
            }
        }
    }

    public func stopMonitoring(geotification: Geotification) {
      for region in locationManager.monitoredRegions {
        guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
        locationManager.stopMonitoring(for: circularRegion)
      }
    }
    
    
    
    public func startMonitoringforGeoFencing(info: Geotification,completion:@escaping ((CLCircularRegion?, RegionMonitor)->())) {
        requestAuth { [weak self](authorized) in
            guard let _self = self else { return }
            
            if let authorized = authorized, authorized {
                _self.startMonitoring(geotification: info, completion: completion)
            }
        }
    }
    
    private func region(with geotification: Geotification) -> CLCircularRegion {
      let region = CLCircularRegion(center: geotification.coordinate, radius: geotification.radius, identifier: geotification.identifier)
      region.notifyOnEntry = (geotification.eventType == .onEntry)
      region.notifyOnExit = true
      return region
    }
    
    private func startMonitoring(geotification: Geotification, completion: @escaping ((CLCircularRegion?, RegionMonitor)->())) {
      if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
        completion(nil, .invalid)
        return
      }
      
      regionCompletion = completion
      let fenceRegion = region(with: geotification)
      locationManager.startMonitoring(for: fenceRegion)
    }

    fileprivate func requestAuth(_ didFinish: @escaping (Bool?) -> Void) {
        didFinishAuthorized = didFinish
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true

    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
        return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
    }
    
    fileprivate func showLocationDisabledPopUp() {
        let alertController = UIAlertController(title: "Location Access Disabled",
                                                message: "Please enable location access",
                                                preferredStyle: .alert)
        
        let openAction = UIAlertAction(title: "Open Settings", style: .default) { (_) in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: self.convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
            }
        }
        alertController.addAction(openAction)
        
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
    }
    
}

extension LocationHandler: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied  {
            showLocationDisabledPopUp()
        } else if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            didFinishAuthorized?(true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location Manager failed with the following error: \(error)")
    }
    
}

extension LocationHandler {
  
  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    if region is CLCircularRegion {
        regionCompletion?(region as? CLCircularRegion, .onEntry)
    }
  }
  
  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLCircularRegion {
        regionCompletion?(region as? CLCircularRegion, .onExit)
    }
  }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Monitoring failed for region with identifier: \(region!.identifier)")
        regionCompletion?(nil, .failed)

    }
}

