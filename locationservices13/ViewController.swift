//
//  ViewController.swift
//  locationservices13
//
//  Created by Ganesh Subramanian on 3/24/20.
//  Copyright © 2020 Ganesh Subramanian. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let locationService: LocationService = LocationService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func findLocation(_ sender: Any) {
        locationService.requestLocationPermissions(level: .always) { [weak self] status in
            self?.locationService.startLocationUpdates()
            print("LOC > \(status.asString)")
        }
    }
    
    @IBAction func checkout(_ sender: Any) {
        locationService.requestLocationPermissions(level: .whenInUse) { [weak self] status in
            self?.locationService.startLocationUpdates()
            print("LOC > \(status.asString)")
        }
    }
}

