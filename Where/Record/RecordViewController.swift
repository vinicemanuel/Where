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
import Combine

class RecordViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    
    private var isRecording = false
    private var shouldCenterLocation = false
    private var shouldShowAllOtherRoutes = false
    private var lastLocation: CLLocation?
    private var workout = Workout()
    private var oldWorkouts: [Workout] = []
    private var routeOverlay: CustonPolyline? = nil
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        LocationManager.shared.subscribe().sink { locations in
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
        .store(in: &subscriptions)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.stopButton.alpha = 0
        LocationManager.shared.requestLocationAuthorization()
        self.configMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func animateButtons() {
         UIView.transition(with: self.playPauseButton, duration: 0.3, options: .transitionFlipFromBottom) {
             self.playPauseButton.alpha = self.isRecording ? 1 : 0
             self.view.layoutIfNeeded()
         }
        
        UIView.transition(with: self.playPauseButton, duration: 0.3, options: .transitionFlipFromTop) {
            self.stopButton.alpha = self.isRecording ? 0 : 1
            self.view.layoutIfNeeded()
        }
     }
    
    private func configMap() {
        self.mapView.showsUserLocation = true
        
        self.mapView.delegate = self
        
        self.shouldCenterLocation = true
        LocationManager.shared.locationManager.requestLocation()
    }
    
    private func centerInMap(for location: CLLocationCoordinate2D) {
        self.mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 100, maxCenterCoordinateDistance: 3000), animated: true)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        self.mapView.setRegion(region, animated: true)
        self.mapView.setCenter(location, animated: true)
    }
    
    private func showWithoutPermissionAlert() {
        let alert = UIAlertController(title: "Location denied", message: "Please, go to settings and enable location permission for Where app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func updateMapView() {
        if let overlay = self.routeOverlay {
            self.mapView.removeOverlay(overlay)
        }
        
        if self.shouldShowAllOtherRoutes == false {
            self.mapView.removeOverlays(self.mapView.overlays)
        }
        
        self.routeOverlay = CustonPolyline(coordinates: self.workout.route, count: self.workout.route.count)
        self.routeOverlay?.color = UIColor.blue.withAlphaComponent(0.9)
        self.mapView.addOverlay(self.routeOverlay!)
    }
    
    private func restart() {
        self.workout.clear()
        self.updateMapView()
        
        if self.shouldShowAllOtherRoutes {
            self.configOldersWorkouts()
        }
    }
    
    private func save() {
        DatabaseHelper.shared.saveWorkout(workout: self.workout)
        self.showSavedAlert()
        self.restart()
    }
    
    private func showSavedAlert() {
        let alert = UIAlertController(title: "Route saved", message: "", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func showSaveRouteALert() {
        let alert = UIAlertController(title: "Would you like to save this route?", message: "", preferredStyle: .alert)
    
        let yesAction = UIAlertAction(title: "YES", style: .default, handler: { _ in
            self.save()
        })
        
        let noAction = UIAlertAction(title: "NO", style: .destructive, handler: { _ in
            self.restart()
        })
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func configOldersWorkouts() {
        let activities = DatabaseHelper.shared.getAllActivities()
        let workouts = activities.map(self.convertActivityToWorkout(activity:))
        self.oldWorkouts = workouts
        
        let overlays = self.oldWorkouts.map(self.workoutToPolylineOveraly(workout:))
        
        self.shouldShowAllOtherRoutes = true
        self.mapView.addOverlays(overlays)
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
        overlay.color = UIColor.yellow.withAlphaComponent(0.9)
        return overlay
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        let isAuthorized = LocationManager.shared.deviceLocationIsAuthorized()
        if isAuthorized {
            if let location = self.lastLocation {
                self.centerInMap(for: location.coordinate)
            }
            LocationManager.shared.locationManager.startUpdatingLocation()
            self.animateButtons()
            self.isRecording = true
        } else {
            self.showWithoutPermissionAlert()
        }
    }
    
    @IBAction func mapVisualizationDidChange(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.shouldShowAllOtherRoutes = false
            self.updateMapView()
        } else {
            self.configOldersWorkouts()
        }
    }
    
    @IBAction func stopButtonPressed(_ sender: Any) {
        LocationManager.shared.locationManager.stopUpdatingLocation()
        self.animateButtons()
        self.isRecording = false
        
        self.showSaveRouteALert()
        print(self.workout)
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        self.shouldCenterLocation = true
        if let location = self.lastLocation {
            self.centerInMap(for: location.coordinate)
        }
        LocationManager.shared.locationManager.requestLocation()
    }
        
    //MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        print("draw route")
        if (!self.isRecording && !self.shouldShowAllOtherRoutes) {
            return MKOverlayRenderer()
        }
        
        if let routePolyline = overlay as? CustonPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = routePolyline.color
            renderer.lineWidth = 7
            return renderer
        }

        return MKOverlayRenderer()
    }
}
