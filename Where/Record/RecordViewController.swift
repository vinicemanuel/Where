//
//  RecordViewController.swift
//  Where
//
//  Created by Vinicius Silva on 08/11/21.
//

import UIKit
import MapKit
import CoreLocation

class RecordViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var verticalSpacePlayPause: NSLayoutConstraint!
    
    private let hiddenStopButtonValue: CGFloat = -50
    private let showStopButtonValue: CGFloat = 20
    private var isRecording = false
    private var shouldCenterLocatin = false
    private var lastLocation: CLLocationCoordinate2D?
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.requestLocation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.configMap()
    }
    
    private func configMap() {
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        self.shouldCenterLocatin = true
        self.locationManager.requestLocation()
    }
    
    private func configLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.activityType = .fitness
        self.locationManager.distanceFilter = 1
    }
    
    private func centerInMap(for location: CLLocationCoordinate2D) {
        self.mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 100, maxCenterCoordinateDistance: 10000), animated: true)
        self.mapView.setCenter(location, animated: true)
    }
    
    private func requestLocation() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    private func deviceLocationIsAuthorized() -> Bool {
        return self.locationManager.authorizationStatus == .authorizedWhenInUse || self.locationManager.authorizationStatus == .authorizedAlways
    }
    
    private func withoutPermission() {
        let alert = UIAlertController(title: "Location denied", message: "Please, go to settings and enable location permission for Where app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func animateButtons() {
        self.verticalSpacePlayPause.constant = self.isRecording ? self.hiddenStopButtonValue : self.showStopButtonValue
        let newImage = self.isRecording ? UIImage(systemName: "play.fill")! : UIImage(systemName: "pause.fill")!
        
        UIView.transition(with: self.playPauseButton, duration: 0.3, options: .transitionFlipFromBottom) {
            self.playPauseButton.setImage(newImage, for: .normal)
            self.view.layoutIfNeeded()
        }
    }
    
    private func startOrPauseRecordLocation() {
        if !self.isRecording {
            self.locationManager.startUpdatingLocation()
        } else {
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        let isAuthorized = self.deviceLocationIsAuthorized()
        if isAuthorized {
            self.animateButtons()
            self.startOrPauseRecordLocation()
            self.isRecording.toggle()
        } else {
            self.withoutPermission()
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        print("stop")
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        if let location = self.lastLocation {
            self.centerInMap(for: location)
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            print("authorized")
            
        case .notDetermined:
            self.requestLocation()
            
        case .denied:
            print("location denied")
            
        case .restricted:
            print("restricted")
            
        default:
            print("default")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        
        if let location = locations.last, self.shouldCenterLocatin {
            self.centerInMap(for: location.coordinate)
        }
        
        self.lastLocation = locations.last?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error.localizedDescription)")
    }
    
    //MARK: - MKMapViewDelegate
}
