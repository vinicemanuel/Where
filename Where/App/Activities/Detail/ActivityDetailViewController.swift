//
//  ActivityDetailViewController.swift
//  Where
//
//  Created by vinicius emanuel on 10/06/22.
//

import UIKit
import MapKit

protocol ActivityDetailDelegate: AnyObject {
    func deletedActivity()
}

class ActivityDetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var deleteActivity: UIButton!
    @IBOutlet weak var mapActivities: MKMapView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private var modelView: ActivityDetailViewModel!
    var activity: Activity!
    weak var delegate: ActivityDetailDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.deleteActivity.layer.cornerRadius = self.deleteActivity.frame.height / 2

        self.mapActivities.delegate = self
        self.modelView = ActivityDetailViewModel(activity: activity)
        self.configView()
        self.configMap()
    }
    
    private func configView() {
        self.dateLabel.text = self.modelView.dateString
        self.distanceLabel.text = self.modelView.distanceString
    }
    
    private func configMap() {
        self.configOldRoutes()
        self.configCurrentRoute()
    }
    
    private func configOldRoutes() {
        let overlays = self.modelView.getOldRouteOverlay()
        self.mapActivities.addOverlays(overlays)
    }
    
    private func configCurrentRoute() {
        let center = self.modelView.center
        let straightDistance = self.modelView.straightDistance
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: straightDistance * 1.2, longitudinalMeters: straightDistance * 1.2)
        self.mapActivities.setRegion(region, animated: false)
        
        let overlay = self.modelView.overlay
        overlay.color = Colors.currentRouteColor
        self.mapActivities.addOverlay(overlay)
    }
    
    @IBAction func deleteActivityTaped(_ sender: Any) {
        let deleted = self.modelView.deleteActicity(activity: activity)
        if deleted {
            self.dismiss(animated: true)
            self.delegate?.deletedActivity()
        } else {
            let alert = UIAlertController(title: "Error", message: "Error trying to delete route.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            
            self.present(alert, animated: true, completion: nil)
        }
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
