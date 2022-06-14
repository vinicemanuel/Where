//
//  RecordViewModel.swift
//  Where
//
//  Created by Vinicius Silva on 04/03/22.
//

import Foundation
import CoreLocation
import Combine


protocol RecordViewModelDelegate: MapViewOlderRouteDelegate {
    func askForLastLocation(lastLocationClosure: @escaping (CLLocation) -> Void)
    func configSubscriptionForLocationsUpdate(locationsClosure: @escaping ([CLLocation]) -> Void)
    
    func getCurrentRouteOverlay() -> CustonPolyline
    
    func saveCurrentWorkout()
    func discartCurrentWorkout()
    
    func startRecordWorkout()
    func stopRecordWorkout()
    
    func requestLocationAuthorization()
    func isDeviceLocationIsAuthorized() -> Bool
    
    var lastRegisteredLocation: CLLocation? { get }
}

class RecordViewModel: NSObject, RecordViewModelDelegate, CLLocationManagerDelegate {
    private var subscriptions = Set<AnyCancellable>()
    private var lastLocation: CLLocation?
    private var workout = Workout()
    private var oldWorkouts: [Workout] = []
    private var lastLocationClosure: ((CLLocation) -> Void)?
    private let workoutManager: WorkoutDelegate
    private let databaseManager: DatabaseDelegate
    private let authorizationManager: AuthorizationDelegate
    
    let locationManager = CLLocationManager()
    
    init(workoutManager: WorkoutDelegate = WorkoutManager.shared,
         databaseManager: DatabaseDelegate = DatabaseManager.shared,
         authorizationManager: AuthorizationDelegate = WorkoutManager.shared)
    {
        self.workoutManager = workoutManager
        self.databaseManager = databaseManager
        self.authorizationManager = authorizationManager
        super.init()
        self.configLocationManager()
    }
    
    private func configLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func configSubscriptionForLocationsUpdate(locationsClosure: @escaping ([CLLocation]) -> Void) {
        self.workoutManager.subscribeForUpdates().sink { locations in
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
        self.workoutManager.startUpdate()
    }
    
    func stopRecordWorkout() {
        self.workoutManager.stopUpdate()
    }
    
    func getCurrentRouteOverlay() -> CustonPolyline {
        CustonPolyline(coordinates: self.workout.route, count: self.workout.route.count)
    }
    
    func askForLastLocation(lastLocationClosure: @escaping (CLLocation) -> Void) {
        self.lastLocationClosure = lastLocationClosure
        self.locationManager.requestLocation()
    }
    
    func saveCurrentWorkout() {
        self.databaseManager.saveWorkout(workout: self.workout, date: Date())
    }
    
    func discartCurrentWorkout() {
        self.workout.clear()
    }
    
    func requestLocationAuthorization() {
        self.authorizationManager.requestLocationAuthorization()
    }
    
    func isDeviceLocationIsAuthorized() -> Bool {
        self.authorizationManager.deviceLocationIsAuthorized()
    }
    
    //MARK: - MapViewOlderRouteDelegate
    func getOldRouteOverlay() -> [CustonPolyline] {
        let activities = self.databaseManager.getAllActivities()
        let workouts = activities.map( { $0.convertToWorkout() } )
        self.oldWorkouts = workouts
        
        let overlays = self.oldWorkouts.map( { $0.convertToPolylineOveraly() } )
        
        return overlays
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
