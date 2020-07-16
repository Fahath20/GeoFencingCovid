//
//  Utils.swift
//  Geofencing
//
//  Created by Fahath Rajak on 13/07/20.
//  Copyright © 2020 Fahath. All rights reserved.
//

import Foundation
import UIKit
import MapKit

let radius = 2000

let deviceFoundMsg = "Device found near by you"

struct PreferencesKeys {
  static let savedItems = "savedItems"
}

extension UIViewController {
  func showAlert(withTitle title: String?, message: String?) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}

extension MKMapView {
  func zoomToUserLocation() {
    guard let coordinate = userLocation.location?.coordinate else { return }
    let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
    setRegion(region, animated: true)
  }
}

extension Date {
    func minutes(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.minute], from: sinceDate, to: self).minute
    }
    
    func seconds(sinceDate: Date) -> Int? {
        return Calendar.current.dateComponents([.second], from: sinceDate, to: self).second
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        
        return base
    }
}

struct CustomNotification {
    static func send(with msg: String, title: String = "") {
        if UIApplication.shared.applicationState == .active {
            let alertController = UIAlertController(title: title,
                                                    message: msg,
            preferredStyle: .alert)
            let openAction = UIAlertAction(title: "Close", style: .default)
            alertController.addAction(openAction)
            UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
        } else {
            // Otherwise present a local notification
            let notificationContent = UNMutableNotificationContent()
            notificationContent.body = msg
            notificationContent.title = title
            notificationContent.sound = UNNotificationSound.default
            //notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
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
}

enum RegionMonitor {
    case onEntry
    case onExit
    case invalid
    case failed
    
    func message() -> String {
        switch self {
        case .onEntry:
            return "You entered region"
        case .onExit:
            return "You exit region"
        case .failed:
            return "Service failed"
        default:
            return "Geofencing is not supported on this device!"
        }
    }
}

enum ZoneAlert {
    case red, yellow, green
    func message() -> String {
        switch self {
        case .red:
            return "Red Zone"
        case .yellow:
            return "Yellow Zone"
        case .green:
            return "Green Zone"
        }
    }
}
