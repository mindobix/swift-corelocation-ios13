//
//  LocationService.swift
//  locationservices13
//
//  Created by Ganesh Subramanian on 3/24/20.
//  Copyright © 2020 Ganesh Subramanian. All rights reserved.
//

import Foundation
import CoreLocation

typealias LocationResult = Result<CLLocation, LocationError>

enum LocationError: LocalizedError {
    case unknownLocation
    case outdatedLocation
    case other(Error)

    var errorDescription: String? {
        switch self {
        case .unknownLocation:
            return "Could not get user location."
        case .outdatedLocation:
            return "User location outdated."
        case .other(let error):
            return "Error: \(error.localizedDescription)"
        }
    }
}

enum AuthorizationLevel {
       case whenInUse, always
}

class LocationService: NSObject {
    
   
    
    private let locationManager: CLLocationManager
    
    var authorizationCallback: ((CLAuthorizationStatus) -> Void)?
    var locationCallback: ((LocationResult) -> Void)?
    
    var authorizationLevel: AuthorizationLevel
    
    /// Returns the status of location authorization
    var authorizationStatus: CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    init(manager: CLLocationManager = CLLocationManager(),
         level: AuthorizationLevel = .whenInUse) {
        locationManager = manager
        authorizationLevel = level
        super.init()
        locationManager.allowsBackgroundLocationUpdates = true
        if #available(iOS 11.0, *) {
            locationManager.showsBackgroundLocationIndicator = true
        }
        //locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.delegate = self
        
    }
    
    func requestLocationPermissions(level: AuthorizationLevel = .whenInUse,
                                   completion: @escaping (CLAuthorizationStatus) -> Void) {
        
        authorizationLevel = level
        if authorizationStatus == .notDetermined {
            print("LOC > requestLocationPermissions > Authorization not determined. Proceeding to ask permissions normally.")
            authorizationCallback = completion
            switch authorizationLevel {
            case .always:
                locationManager.requestAlwaysAuthorization()
            case .whenInUse:
                locationManager.requestWhenInUseAuthorization()
            }
        } else {
            print("LOC > requestLocationPermissions > Permissions in locked state, no action will be taken.")
            //locationManager.allowsBackgroundLocationUpdates = true
            //if #available(iOS 11.0, *) {
            //    locationManager.showsBackgroundLocationIndicator = true
            //}
            completion(authorizationStatus)
        }
    }
    
    func startLocationUpdates() {
        guard [.authorizedWhenInUse, .authorizedAlways].contains(authorizationStatus) else { return }
        locationManager.startUpdatingLocation()
    }
    
    /// Request the user's location using a completion handler.
    ///
    /// - Parameter completion: The function to execute using the
    ///   result of the request for a user's location.
    func getUpdatedLocation(completion: @escaping (LocationResult) -> Void) {
        guard [.authorizedWhenInUse, .authorizedAlways]
            .contains(authorizationStatus) else { completion(.failure(.unknownLocation)); return }
        locationCallback = completion
        locationManager.requestLocation()
    }
}

// MARK: - CLLocationManagerDelegate authorization functions
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("LOC > locationManager > didChangeAuthorization > CLAuthorizationStatus - \(status.asString)")
        if [.authorizedWhenInUse, .authorizedAlways].contains(status) {
            manager.requestLocation()
        }
        authorizationCallback?(status)
        authorizationCallback = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            locationCallback?(.failure(.unknownLocation))
            locationCallback = nil
            return
        }
        print("LOC > locationManager > didUpdateLocations > User location: \(location.coordinate)")
        locationCallback?(.success(location))
        locationCallback = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LOC > locationManager > didFailWithError - \(error)")
        locationCallback?(.failure(.other(error)))
        locationCallback = nil
    }
}

extension CLAuthorizationStatus {
    var asString: String {
        switch self {
        case .notDetermined:
            return "Not determined"
        case .authorizedWhenInUse:
            return "When in use"
        case .authorizedAlways:
            return "Always"
        case .restricted:
            return "Restricted"
        case .denied:
            return "Denied"
        default:
           return "Denied"
        }
    }
}
