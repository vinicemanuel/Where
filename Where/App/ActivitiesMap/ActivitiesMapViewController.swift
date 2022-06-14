//
//  ActivitiesMapViewController.swift
//  Where
//
//  Created by Vinicius Silva on 09/12/21.
//

import UIKit
import MapKit

class ActivitiesMapViewController: UIViewController, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var modelView: ActivitiesMapViewModelDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.modelView = ActivitiesMapViewModel()
        self.configMap()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.modelView.askForLastLocation { location in
            self.centerInMap(for: location.coordinate)
        }
        self.configOldersWorkouts()
    }
    
    private func centerInMap(for location: CLLocationCoordinate2D) {
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 500, longitudinalMeters: 500)
        self.mapView.setRegion(region, animated: true)
    }
    
    private func configMap() {
        self.mapView.showsUserLocation = true
        self.mapView.delegate = self
    }
    
    private func configOldersWorkouts() {
        self.mapView.removeOverlays(self.mapView.overlays)
        let overlays = self.modelView.getOldRouteOverlay()
        self.mapView.addOverlays(overlays)
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
