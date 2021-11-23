//
//  RecordViewController.swift
//  Where
//
//  Created by Vinicius Silva on 08/11/21.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class RecordViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var verticalSpacePlayPause: NSLayoutConstraint!
    
    private let hiddenStopButtonValue: CGFloat = -50
    private let showStopButtonValue: CGFloat = 20
    private var isRecording = false
    private var shouldCenterLocation = false
    private var lastLocation: CLLocation?
    private var workout = Workout()
    
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
    
    private func animateButtons() {
         self.verticalSpacePlayPause.constant = self.isRecording ? self.hiddenStopButtonValue : self.showStopButtonValue
        let alpha: CGFloat = self.isRecording ? 1 : 0
         
         UIView.transition(with: self.playPauseButton, duration: 0.3, options: .transitionFlipFromBottom) {
             self.playPauseButton.alpha = alpha
             self.view.layoutIfNeeded()
         }
     }
    
    private func configMap() {
        self.mapView.showsUserLocation = true
        self.mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 100, maxCenterCoordinateDistance: 10000), animated: true)
        self.mapView.delegate = self
        
        self.shouldCenterLocation = true
        self.locationManager.requestLocation()
    }
    
    private func configLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func centerInMap(for location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 50, longitudinalMeters: 50)
        self.mapView.setRegion(region, animated: true)
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
    
    private func updateMapView() {
        self.mapView.removeOverlays(self.mapView.overlays)
        let overlay = MKPolyline(coordinates: self.workout.route, count: self.workout.route.count)
        self.mapView.addOverlay(overlay)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        let isAuthorized = self.deviceLocationIsAuthorized()
        if isAuthorized {
            if let location = self.lastLocation {
                self.centerInMap(for: location.coordinate)
            }
            self.locationManager.startUpdatingLocation()
            self.animateButtons()
            self.isRecording = true
        } else {
            self.withoutPermission()
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        print("stop")
        self.locationManager.stopUpdatingLocation()
        self.animateButtons()
        self.isRecording = false
        print(self.workout)
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        self.shouldCenterLocation = true
        if let location = self.lastLocation {
            self.centerInMap(for: location.coordinate)
        }
        self.locationManager.requestLocation()
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
        if let location = locations.last, self.shouldCenterLocation {
            self.centerInMap(for: location.coordinate)
            self.workout.updateWithNextLocation(nextLocation: location)
            self.updateMapView()
            
            if self.isRecording {
                self.updateMapView()
            }
            
            self.lastLocation = location
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    //MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if (!self.isRecording) {
            return MKOverlayRenderer()
        }
        
        if let routePolyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = UIColor.blue.withAlphaComponent(0.9)
            renderer.lineWidth = 7
            return renderer
        }

        return MKOverlayRenderer()
    }
}
