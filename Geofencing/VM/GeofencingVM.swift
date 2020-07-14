//
//  GeofencingVM.swift
//  Geofencing
//
//  Created by Fahath Rajak on 13/07/20.
//  Copyright © 2020 Fahath. All rights reserved.
//

import MapKit
import CoreLocation

protocol GeoFencingDelegate {
    func startMonitoring()
    func stopMonitoring()
}

class GeofencingVM: GeoFencingDelegate {
    lazy private var locationHandler: LocationHandler = {
        return LocationHandler()
    }()
    
    var geotificationInfo: Geotification
    
    init(info: Geotification) {
        geotificationInfo = info
    }
    func startMonitoring() {
        
        locationHandler.startMonitoringforGeoFencing(info: geotificationInfo) { (region, message) in
            if let region = region {
                self.handleEvent(for: region, message)
            }
        }
    }
    
    func stopMonitoring() {
        locationHandler.stopMonitoring(geotification: geotificationInfo)
    }
    
    func handleEvent(for region: CLRegion!, _ message: String) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            guard let _ = note(from: region.identifier) else { return }
            let alertController = UIAlertController(title: region.identifier,
            message: message,
            preferredStyle: .alert)
            let openAction = UIAlertAction(title: "Close", style: .default)
            alertController.addAction(openAction)
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        } else {
            // Otherwise present a local notification
            guard let body = note(from: region.identifier) else { return }
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = body + message
            notificationContent.sound = UNNotificationSound.default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
            let request = UNNotificationRequest(identifier: "location_change",
                                                content: notificationContent,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error: \(error)")
                }
            }
        }
    }
    
    func note(from identifier: String) -> String? {
        let geotifications = Geotification.allGeotifications()
        guard let matched = geotifications.filter({
            $0.identifier == identifier
        }).first else { return nil }
        return matched.note
    }
}

