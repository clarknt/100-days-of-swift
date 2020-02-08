//
//  ViewController.swift
//  Project22
//

import CoreLocation
import UIKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet var distanceReading: UILabel!
    // challenge 2
    @IBOutlet var nameLabel: UILabel!
    // challenge 3
    @IBOutlet var circleView: UIView!
    
    var locationManager: CLLocationManager?
    
    var firstDetection: Bool = true
    var currentBeaconUuid: UUID?

    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()
        
        view.backgroundColor = .gray
        nameLabel.text = "Unknown"
        
        // challenge 3
        circleView.layer.cornerRadius = 128
        circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            // is this device able to monitor iBeacons?
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    startScanning()
                }
            }
        }
    }
    
    func startScanning() {
        addBeaconRegion(uuidString: "5A4BCFCE-174E-4BAC-A814-092E77F6B7E5", major: 123, minor: 456, identifier: "Apple AirLocate")
        addBeaconRegion(uuidString: "2F234454-CF6D-4A0F-ADF2-F4911BA9FFA6", major: 123, minor: 456, identifier: "Radius Networks")
        addBeaconRegion(uuidString: "92AB49BE-4127-42F4-B532-90fAF1E26491", major: 123, minor: 456, identifier: "TwoCanoes")
    }
    
    func addBeaconRegion(uuidString: String, major: CLBeaconMajorValue, minor: CLBeaconMinorValue, identifier: String) {
        let uuid = UUID(uuidString: uuidString)!
        let beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: major, minor: minor, identifier: identifier)
        
        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }
    
    func update(distance: CLProximity, name: String) {
        UIView.animate(withDuration: 1) { [weak self] in
            // challenge 2
            self?.nameLabel.text = "\(name)"

            switch distance {
            case .far:
                self?.view.backgroundColor = .blue
                self?.distanceReading.text = "FAR"
                // challenge 3
                self?.circleView.transform = CGAffineTransform(scaleX: 0.25, y: 0.25)
                
            case .near:
                self?.view.backgroundColor = .orange
                self?.distanceReading.text = "NEAR"
                // challenge 3
                self?.circleView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)

            case .immediate:
                self?.view.backgroundColor = .red
                self?.distanceReading.text = "RIGHT HERE"
                // challenge 3
                self?.circleView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)

            case .unknown:
                fallthrough
                
            default:
                self?.view.backgroundColor = .gray
                self?.distanceReading.text = "UNKNWON"
                self?.nameLabel.text = "Unknown"
                // challenge 3
                self?.circleView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            }
        }
    }

    // challenge 1
    func showFirstDetection() {
        if firstDetection {
            firstDetection = false
            let ac = UIAlertController(title: "Beacon detected", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            // challenge 2
            // deal with one beacon at once
            if currentBeaconUuid == nil { currentBeaconUuid = region.proximityUUID }
            guard currentBeaconUuid == region.proximityUUID else { return }

            update(distance: beacon.proximity, name: region.identifier)

            // challenge 1
            showFirstDetection()
        }
        else {
            // challenge 2
            // deal with one beacon at once
            guard currentBeaconUuid == region.proximityUUID else { return }
            currentBeaconUuid = nil
            
            update(distance: .unknown, name: "Unknown")
        }
    }
}

