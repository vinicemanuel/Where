//
//  RecordViewController.swift
//  Where
//
//  Created by Vinicius Silva on 08/11/21.
//

import UIKit
import MapKit
import CoreLocation

class RecordViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var verticalSpacePlayPause: NSLayoutConstraint!
    
    private let hiddenStopButtonValue: CGFloat = -50
    private let showStopButtonValue: CGFloat = 20
    private var isRecording = false
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.requestLocation()
    }
    
    func requestLocation() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func deviceLocationIsAuthorized() -> Bool {
        return self.locationManager.authorizationStatus == .authorizedWhenInUse || self.locationManager.authorizationStatus == .authorizedAlways
    }
    
    func withoutPermission() {
        let alert = UIAlertController(title: "Location denied", message: "Please, go to settings and enable location permission for Where app", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func playPauseButtonPressed(_ sender: Any) {
        let isAuthorized = self.deviceLocationIsAuthorized()
        if isAuthorized {
            animateButtons()
            //start or pause record
        } else {
            self.withoutPermission()
        }
    }
    
    private func animateButtons() {
        self.verticalSpacePlayPause.constant = self.isRecording ? self.hiddenStopButtonValue : self.showStopButtonValue
        let newImage = self.isRecording ? UIImage(systemName: "play.fill")! : UIImage(systemName: "pause.fill")!
        
        self.isRecording.toggle()
        
        UIView.transition(with: self.playPauseButton, duration: 0.3, options: .transitionFlipFromBottom) {
            self.playPauseButton.setImage(newImage, for: .normal)
            self.view.layoutIfNeeded()
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
}
