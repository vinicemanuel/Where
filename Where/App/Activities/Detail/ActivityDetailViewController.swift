//
//  ActivityDetailViewController.swift
//  Where
//
//  Created by vinicius emanuel on 10/06/22.
//

import UIKit
import MapKit

class ActivityDetailViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var deleteActivity: UIButton!
    @IBOutlet weak var mapActivities: MKMapView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    private var viewModelDelegate: ActivityDetailViewModelDelegate!
    var activity: Activity!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.deleteActivity.layer.cornerRadius = self.deleteActivity.frame.height / 2

        self.mapActivities.delegate = self
        self.viewModelDelegate = ActivityDetailViewModel(activity: activity)
    }
    
    @IBAction func deleteActivityTaped(_ sender: Any) {
        
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
