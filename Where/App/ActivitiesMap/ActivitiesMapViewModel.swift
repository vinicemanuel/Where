//
//  ActivitiesMapViewModel.swift
//  Where
//
//  Created by Vinicius Silva on 05/03/22.
//

import Foundation
import CoreLocation

protocol ActivitiesMapViewModelDelegate: MapViewOlderRouteDelegate {
    func askForLastLocation(lastLocationClosure: @escaping (CLLocation) -> Void)
}

class ActivitiesMapViewModel: NSObject, ActivitiesMapViewModelDelegate, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private var lastLocationClosure: ((CLLocation) -> Void)?
    private let databaseManager: DatabaseDelegate
    
    init(databaseManager: DatabaseDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
        super.init()
        self.configLocationManager()
    }
    
    private func configLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    //MARK: - ActivitiesMapViewDelegate
    func askForLastLocation(lastLocationClosure: @escaping (CLLocation) -> Void) {
        self.lastLocationClosure = lastLocationClosure
        self.locationManager.requestLocation()
    }
    
    //MARK: - MapViewOlderRouteDelegate
    func getOldRouteOverlay() -> [CustonPolyline] {
        let activities = self.databaseManager.getAllActivities()
        let workouts = activities.map( { $0.convertToWorkout() } )
        let overlays = workouts.map( { $0.convertToPolylineOveraly() } )
        return overlays
    }

    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.locationManager.stopUpdatingLocation()
            self.lastLocationClosure?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
