//
//  ActivitiesMapViewController.swift
//  Where
//
//  Created by Vinicius Silva on 09/12/21.
//

import UIKit
import MapKit

class ActivitiesMapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configMap()
        self.configLocationManager()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configOldersWorkouts()
    }
    
    private func centerInMap(for location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        self.mapView.setRegion(region, animated: true)
    }
    
    private func configLocationManager() {
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func configMap() {
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
        self.locationManager.startUpdatingLocation()
    }
    
    private func configOldersWorkouts() {
        let activities = DatabaseHelper.shared.getAllActivities()
        let workouts = activities.map(self.convertActivityToWorkout(activity:))
        
        let overlays = workouts.map(self.workoutToPolylineOveraly(workout:))
        
        self.mapView.addOverlays(overlays)
    }
    
    private func workoutToPolylineOveraly(workout: Workout) -> CustonPolyline {
        let overlay = CustonPolyline(coordinates: workout.route, count: workout.route.count)
        overlay.color = UIColor.yellow.withAlphaComponent(0.9)
        return overlay
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
    
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            self.centerInMap(for: location.coordinate)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error: \(error.localizedDescription)")
    }
    
    //MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        if let routePolyline = overlay as? CustonPolyline {
            let renderer = MKPolylineRenderer(polyline: routePolyline)
            renderer.strokeColor = routePolyline.color
            renderer.lineWidth = 7
            return renderer
        }

        return MKOverlayRenderer()
    }
}
