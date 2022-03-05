//
//  ActivityTableViewCell.swift
//  Where
//
//  Created by Vinicius Silva on 09/11/21.
//

import UIKit
import MapKit
import CoreLocation

class ActivityTableViewCell: UITableViewCell, MKMapViewDelegate {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    private var viewModelDelegate: ActivityCellViewModelProtocol!
    
    private var activity: Activity!
    
    static let cellID = "activityCell"
    
    func configWith(activity: Activity) {
        self.viewModelDelegate.configWith(activity: activity)
        
        let center = self.viewModelDelegate.center
        let straightDistance = self.viewModelDelegate.straightDistance
        
        let region = MKCoordinateRegion(center: center, latitudinalMeters: straightDistance * 1.2, longitudinalMeters: straightDistance * 1.2)
        self.mapView.setRegion(region, animated: false)
        
        self.mapView.removeOverlays(self.mapView.overlays)
        let overlay = self.viewModelDelegate.overlay
        overlay.color = Colors.oldRoutesColor
        self.mapView.addOverlay(overlay)
        
        self.dateLabel.text = self.viewModelDelegate.dateString
        self.distanceLabel.text = self.viewModelDelegate.distanceString
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewModelDelegate = ActivityCellViewModel()
        self.mapView.delegate = self
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
