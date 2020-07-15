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
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        geoFencingVM.startMonitoring()
        button.addTarget(self, action: #selector(showBLT), for: .touchUpInside)
    }
    
    @objc func showBLT() {
        let vc = BluetoothViewController(bluetoothManager: CoreBluetoothManager())
        present(vc, animated: true, completion: nil)
    }
}
