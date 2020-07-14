//
//  ViewController.swift
//  Geofencing
//
//  Created by Fahath Rajak on 13/07/20.
//  Copyright © 2020 Fahath. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    lazy var geoFencingVM = GeofencingVM()

    override func viewDidLoad() {
        super.viewDidLoad()
        geoFencingVM.startMonitoring()
    }
}
