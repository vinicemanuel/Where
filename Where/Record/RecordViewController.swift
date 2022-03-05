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
    private var shouldShowAllOtherRoutes = false
    private var routeOverlay: CustonPolyline? = nil
    
    var viewModelDelegate: RecordViewModelProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModelDelegate = RecordViewModel(recordLocationsClosure: { locations in
            if let location = locations.last {
                self.centerInMap(for: location.coordinate)
                self.updateMapView()
                if self.isRecording {
                    self.updateMapView()
                }
            }
        })
        
        self.stopButton.alpha = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModelDelegate.requestLocationAuthorization()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.configMap()
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
        self.viewModelDelegate.askForLastLocation { location in
            self.updateMapView(with: location)
        }
    }
    
    private func centerInMap(for location: CLLocationCoordinate2D) {
        self.mapView.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 500, maxCenterCoordinateDistance: 5000), animated: true)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        self.mapView.setRegion(region, animated: true)
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
        
        self.routeOverlay = self.viewModelDelegate.getCurrentRouteOverlay()
        self.routeOverlay?.color = Colors.currentRouteColor
        self.mapView.addOverlay(self.routeOverlay!)
    }
    
    private func updateMapView(with location: CLLocation) {
        self.centerInMap(for: location.coordinate)
        self.updateMapView()
    }
    
    private func restart() {
        self.viewModelDelegate.discartCurrentWorkout()
        self.updateMapView()
        
        if self.shouldShowAllOtherRoutes {
            self.configOldersWorkouts()
        }
    }
    
    private func save() {
        self.viewModelDelegate.saveCurrentWorkout()
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
        let alert = UIAlertController(title: "Would you like to save this route?", message: "", preferredStyle: .actionSheet)
    
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            self.viewModelDelegate.stopRecordWorkout()
            self.animateButtons()
            self.isRecording = false
            self.save()
        })
        
        let discardAction = UIAlertAction(title: "Discard", style: .default, handler: { _ in
            self.viewModelDelegate.stopRecordWorkout()
            self.animateButtons()
            self.isRecording = false
            self.restart()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        
        alert.addAction(saveAction)
        alert.addAction(discardAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    private func configOldersWorkouts() {
        let overlays = self.viewModelDelegate.getOldRouteOverlay()
        self.shouldShowAllOtherRoutes = true
        self.mapView.addOverlays(overlays)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        let isAuthorized = self.viewModelDelegate.isDeviceLocationIsAuthorized()
        if isAuthorized {
            if let location = self.viewModelDelegate.lastRegisteredLocation {
                self.centerInMap(for: location.coordinate)
            }
            self.viewModelDelegate.startRecordWorkout()
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
        self.showSaveRouteALert()
    }
    
    @IBAction func centerButtonPressed(_ sender: Any) {
        if let location = self.viewModelDelegate.lastRegisteredLocation {
            self.centerInMap(for: location.coordinate)
        }
        
        self.viewModelDelegate.askForLastLocation { location in
            self.updateMapView(with: location)
        }
    }
        
    //MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
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
