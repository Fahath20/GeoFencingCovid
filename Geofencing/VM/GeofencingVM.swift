//
//  GeofencingVM.swift
//  Geofencing
//
//  Created by Fahath Rajak on 13/07/20.
//  Copyright © 2020 Fahath. All rights reserved.
//

import MapKit
import CoreLocation

class GeofencingVM {
    lazy private var locationHandler: LocationHandler = {
        return LocationHandler()
    }()
    
    let geoFenceInfo = Geotification(coordinate: CLLocationCoordinate2D(latitude: 20.633748, longitude: -103.413008), radius: CLLocationDistance(radius), identifier: "sdb1", note: "SDB1")
    
    public func startMonitoring() {
        locationHandler.startMonitoringforGeoFencing(info: geoFenceInfo) { (region, message) in
            if let region = region {
                self.handleEvent(for: region, message)
            }
        }
    }
    
    public func stopMonitoring() {
        locationHandler.stopMonitoring(geotification: geoFenceInfo)
    }
    
    private func handleEvent(for region: CLRegion!, _ message: String) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            let alertController = UIAlertController(title: region.identifier,
            message: message,
            preferredStyle: .alert)
            let openAction = UIAlertAction(title: "Close", style: .default)
            alertController.addAction(openAction)
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        } else {
            // Otherwise present a local notification
            CustomNotification.send(with: region.identifier + " " + message)
        }
    }
}

