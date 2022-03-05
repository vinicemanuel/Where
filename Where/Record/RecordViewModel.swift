//
//  RecordViewModel.swift
//  Where
//
//  Created by Vinicius Silva on 04/03/22.
//

import Foundation
import CoreLocation
import Combine


protocol RecordViewModelProtocol {
    func config(locationsClosure: @escaping ([CLLocation]) -> Void)
    func askForLastLocation(lastLocationClosure: @escaping (CLLocation) -> Void)
    
    func getCurrentRouteOverlay() -> CustonPolyline
    func getOldRouteOverlay() -> [CustonPolyline]
    
    func saveCurrentWorkout()
    func discartCurrentWorkout()
    
    func startRecordWorkout()
    func stopRecordWorkout()
    
    func requestLocationAuthorization()
    func isDeviceLocationIsAuthorized() -> Bool
    
    var lastRegisteredLocation: CLLocation? { get }
}

class RecordViewModel: NSObject, RecordViewModelProtocol, CLLocationManagerDelegate {
    private var subscriptions = Set<AnyCancellable>()
    private var lastLocation: CLLocation?
    private var workout = Workout()
    private var oldWorkouts: [Workout] = []
    private var lastLocationClosure: ((CLLocation) -> Void)?
    
    let locationManager = CLLocationManager()
    
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
        return overlay
    }
    
    func configSubscription(locationsClosure: @escaping ([CLLocation]) -> Void) {
        WorkoutManager.shared.subscribe().sink { locations in
            locationsClosure(locations)
            if let location = locations.last {
                self.workout.updateWithNextLocation(nextLocation: location)
                print(self.workout.route.count)
                self.lastLocation = location
            }
        }
        .store(in: &subscriptions)
    }
    
    //MARK: RecordViewModelProtocol
    var lastRegisteredLocation: CLLocation? {
        get {
            return self.lastLocation
        }
    }
    
    func startRecordWorkout() {
        WorkoutManager.shared.locationManager.startUpdatingLocation()
    }
    
    func stopRecordWorkout() {
        WorkoutManager.shared.locationManager.stopUpdatingLocation()
    }
    
    func config(locationsClosure: @escaping ([CLLocation]) -> Void) {
        self.configSubscription(locationsClosure: locationsClosure)
        self.configLocationManager()
    }
    
    func getCurrentRouteOverlay() -> CustonPolyline {
        CustonPolyline(coordinates: self.workout.route, count: self.workout.route.count)
    }
    
    func getOldRouteOverlay() -> [CustonPolyline] {
        let activities = DatabaseManager.shared.getAllActivities()
        let workouts = activities.map(self.convertActivityToWorkout(activity:))
        self.oldWorkouts = workouts
        
        let overlays = self.oldWorkouts.map(self.workoutToPolylineOveraly(workout:))
        
        return overlays
    }
    
    func askForLastLocation(lastLocationClosure: @escaping (CLLocation) -> Void) {
        self.lastLocationClosure = lastLocationClosure
        self.locationManager.requestLocation()
    }
    
    func saveCurrentWorkout() {
        DatabaseManager.shared.saveWorkout(workout: self.workout)
    }
    
    func discartCurrentWorkout() {
        self.workout.clear()
    }
    
    func requestLocationAuthorization() {
        WorkoutManager.shared.requestLocationAuthorization()
    }
    
    func isDeviceLocationIsAuthorized() -> Bool {
        WorkoutManager.shared.deviceLocationIsAuthorized()
    }
    
    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.lastLocation = location
            self.lastLocationClosure?(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
