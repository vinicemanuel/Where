//
//  ActivitiesMapViewModel.swift
//  Where
//
//  Created by Vinicius Silva on 05/03/22.
//

import Foundation
import CoreLocation

protocol ActivitiesMapViewModelDelegate {
    func askForLastLocation(lastLocationClosure: @escaping (CLLocation) -> Void)
    func getOldRouteOverlay() -> [CustonPolyline]
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
    
    private func convertActivityToWorkout(activity: Activity) -> Workout {
        let workout = Workout()
        
        guard let locations: NSOrderedSet = activity.locations,
        let locationsArray = locations.array as? [Location] else {
            return workout
        }
        
        let workoutRoute = locationsArray.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
        workout.route = workoutRoute
        
        return workout
    }
    
    private func workoutToPolylineOveraly(workout: Workout) -> CustonPolyline {
        let overlay = CustonPolyline(coordinates: workout.route, count: workout.route.count)
        overlay.color = Colors.oldRoutesColor
        return overlay
    }
    
    //MARK: - ActivitiesMapViewDelegate
    func askForLastLocation(lastLocationClosure: @escaping (CLLocation) -> Void) {
        self.lastLocationClosure = lastLocationClosure
        self.locationManager.requestLocation()
    }
    
    func getOldRouteOverlay() -> [CustonPolyline] {
        let activities = self.databaseManager.getAllActivities()
        let workouts = activities.map(self.convertActivityToWorkout(activity:))
        let overlays = workouts.map(self.workoutToPolylineOveraly(workout:))
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
