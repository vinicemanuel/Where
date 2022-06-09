//
//  WorkoutManager.swift
//  Where
//
//  Created by Vinicius Silva on 08/12/21.
//

import Foundation
import CoreLocation
import Combine

protocol WorkoutProtocol {
    func startUpdate()
    func stopUpdate()
    func subscribeForUpdates() -> AnyPublisher<[CLLocation], Never>
}

protocol AuthorizationProtocol {
    func requestLocationAuthorization()
    func deviceLocationIsAuthorized() -> Bool
}

class WorkoutManager: NSObject, WorkoutProtocol, AuthorizationProtocol, CLLocationManagerDelegate {
    static let shared = WorkoutManager()
    
    private let locationManager = CLLocationManager()
    private let passthroughLocations: PassthroughSubject<[CLLocation], Never>
    
    private override init() {
        self.passthroughLocations = PassthroughSubject<[CLLocation], Never>()
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.allowsBackgroundLocationUpdates = true
    }
    
    //MARK: - RequestAuthorizationProtocol
    func requestLocationAuthorization() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func deviceLocationIsAuthorized() -> Bool {
        return self.locationManager.authorizationStatus == .authorizedWhenInUse || self.locationManager.authorizationStatus == .authorizedAlways
    }
    
    //MARK: - WorkoutProtocol
    func startUpdate() {
        WorkoutManager.shared.locationManager.startUpdatingLocation()
    }
    
    func stopUpdate() {
        WorkoutManager.shared.locationManager.stopUpdatingLocation()
    }
    
    func subscribeForUpdates() -> AnyPublisher<[CLLocation], Never> {
        return self.passthroughLocations.eraseToAnyPublisher()
    }
    
    //MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("authorized")
            
        case .notDetermined:
            self.requestLocationAuthorization()
            
        case .denied:
            print("location denied")
            
        case .restricted:
            print("restricted")
            
        default:
            print("default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.passthroughLocations.send(locations)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
}
