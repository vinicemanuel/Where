//
//  ActivityCellViewModel.swift
//  Where
//
//  Created by Vinicius Silva on 04/03/22.
//

import Foundation
import CoreLocation

class ActivityDetailViewModel: ActivityDetailViewModelDelegate {
    private var activityDate: String = ""
    private var distance: String = ""
    private var distanceMinMax: CLLocationDistance = 0
    private var meanLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    private var activityOverlay: CustonPolyline = CustonPolyline(coordinates: [], count: 0)
    
    init(activity: Activity) {
        self.activityDate = ""
        if let date = activity.date {
            let dateString = self.stringFromDate(date: date)
            activityDate = dateString
        }
        
        if let locations: NSOrderedSet = activity.locations,
           let locationsArray = locations.array as? [Location] {
            self.extractRouteInfo(locationsArray)
        }
    }
    
    private func stringFromDate(date: Date) -> String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "dd/MM/yyyy"
        let string = dateFormater.string(from: date)
        return string
    }
    
    private func extractRouteInfo(_ locationsArray: [Location]) {
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
        
        self.distanceMinMax = CLLocation(latitude: maxLat, longitude: maxLon).distance(from: CLLocation(latitude: minLat, longitude: minLon))
        
        self.meanLocation = CLLocationCoordinate2D(latitude: meanlat, longitude: meanLon)
        
        var distance: Double = 0
        for (first, second) in zip(clLocation, clLocation.dropFirst()) {
            distance = distance + second.distance(from: first)
        }
        
        self.distance = "\(String(format: "%.2f", (distance/1000))) Km"
        
        self.activityOverlay = CustonPolyline(coordinates: clLocationCoordinate2Ds, count: clLocationCoordinate2Ds.count)
    }
    
    //MARK: - ActivityCellViewModelProtocol
    var dateString: String {
        get {
            return self.activityDate
        }
    }
    
    var distanceString: String {
        get {
            return self.distance
        }
    }
    
    var straightDistance: CLLocationDistance {
        get {
            return self.distanceMinMax
        }
    }
    
    var center: CLLocationCoordinate2D {
        get {
            return meanLocation
        }
    }
    
    var overlay: CustonPolyline {
        get {
            return self.activityOverlay
        }
    }
}
