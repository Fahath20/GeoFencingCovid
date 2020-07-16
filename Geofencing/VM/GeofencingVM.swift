//
//  GeofencingVM.swift
//  Geofencing
//
//  Created by Fahath Rajak on 13/07/20.
//  Copyright © 2020 Fahath. All rights reserved.
//

import MapKit
import CoreLocation
import WebKit

class GeofencingVM {
    lazy private var locationHandler: LocationHandler = {
        return LocationHandler()
    }()
    
    lazy private var bltManager: CoreBluetoothManager = {
        let bm = CoreBluetoothManager()
        bm.delegate = self
        return bm
    }()
    
    let geoFenceInfo = Geotification(coordinate: CLLocationCoordinate2D(latitude: 20.633748, longitude: -103.413008), radius: CLLocationDistance(radius), identifier: "sdb1", note: "SDB1")
    
    public func startMonitoring() {
        locationHandler.startMonitoringforGeoFencing(info: geoFenceInfo) { (region, regionMonitor) in
            if let region = region {
                self.handleEvent(for: region, regionMonitor)
                self.handleBLT(regionMonitor)
            }
        }
    }
    
    public func stopMonitoring() {
        locationHandler.stopMonitoring(geotification: geoFenceInfo)
    }
    
    private func handleEvent(for region: CLRegion!, _ regionMonitor: RegionMonitor) {
        CustomNotification.send(with: regionMonitor.message())
    }
    
    private func handleBLT(_ regionMonitor: RegionMonitor) {
        if regionMonitor == .onEntry {
            bltManager.startScanning()
        } else {
            //Stop Scanning
            //bltManager.stopScanning()
        }
    }
}

extension GeofencingVM: BluetoothManagerDelegate {
    func peripheralsDidUpdate() {
        let devices = bltManager.peripherals.mapValues{ $0 }
        if devices.count > 0 {
            CustomNotification.send(with: deviceFoundMsg)
        }
    }
}
