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
    
    private var activity: Activity!
    
    static let cellID = "activityCell"
    
    private func configMap(_ locationsArray: [Location]) {
        var clLocation: [CLLocation] = []
        var clLocationCoordinate2Ds: [CLLocationCoordinate2D] = []
        
        var maxLat: Double = (-1)*(Double.infinity)
        var minLat: Double = (Double.infinity)
        var maxLon: Double = (-1)*(Double.infinity)
        var minLon: Double = (Double.infinity)
        
        locationsArray.forEach { location in
            clLocation.append(CLLocation(latitude: location.latitude, longitude: location.longitude))
            clLocationCoordinate2Ds.append(CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude))
            
            if maxLat < location.latitude {
                maxLat = location.latitude
            }
            
            if minLat > location.latitude {
                minLat = location.latitude
            }
            
            if maxLon < location.longitude {
                maxLon = location.longitude
            }
            
            if minLon > location.longitude {
                minLon = location.longitude
            }
        }
        
        let meanlat = ((maxLat - minLat) / 2) + minLat
        let meanLon = ((maxLon - minLon) / 2) + minLon
        
        let distanceMinMax = CLLocation(latitude: maxLat, longitude: maxLon).distance(from: CLLocation(latitude: minLat, longitude: minLon))
        
        let meanLocation = CLLocationCoordinate2D(latitude: meanlat, longitude: meanLon)
        let region = MKCoordinateRegion(center: meanLocation, latitudinalMeters: distanceMinMax * 1.2, longitudinalMeters: distanceMinMax * 1.2)
        self.mapView.setRegion(region, animated: false)
        
        var distance: Double = 0
        for (first, second) in zip(clLocation, clLocation.dropFirst()) {
            distance = distance + second.distance(from: first)
        }
        
        self.distanceLabel.text = "\(String(format: "%.2f", (distance/1000))) Km"
        
        let overlay = CustonPolyline(coordinates: clLocationCoordinate2Ds, count: clLocationCoordinate2Ds.count)
        overlay.color = Colors.oldRoutesColor
        
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.addOverlay(overlay)
    }
    
    func configWith(activity: Activity) {
        if let date = activity.date {
            let dateString = self.stringFromDate(date: date)
            self.dateLabel.text = dateString
        } else {
            self.dateLabel.text = ""
        }
        
        if let locations: NSOrderedSet = activity.locations,
           let locationsArray = locations.array as? [Location] {
            
            self.configMap(locationsArray)
        }
    }
    
    private func stringFromDate(date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy HH:mm"
        let string = dateFormater.string(from: date)
        return string
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
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
