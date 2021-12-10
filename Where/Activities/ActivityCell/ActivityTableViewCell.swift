//
//  ActivityTableViewCell.swift
//  Where
//
//  Created by Vinicius Silva on 09/11/21.
//

import UIKit
import MapKit
import CoreLocation

class ActivityTableViewCell: UITableViewCell {
    @IBOutlet private weak var mapView: MKMapView!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    
    private var activity: Activity!
    
    static let cellID = "activityCell"
    
    func configWith(activity: Activity) {
        if let date = activity.date {
            let dateString = self.stringFromDate(date: date)
            self.dateLabel.text = dateString
        } else {
            self.dateLabel.text = ""
        }
        
        if let locations: NSOrderedSet = activity.locations,
           let locationsArray = locations.array as? [Location] {
            let corelocations = locationsArray.map({CLLocation(latitude: $0.latitude, longitude: $0.longitude)})
            var distance: Double = 0
            for (first, second) in zip(corelocations, corelocations.dropFirst()) {
                distance = distance + second.distance(from: first)
            }
            
            self.distanceLabel.text = "\(String(format: "%.2f", (distance/1000))) Km"
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
    }
}
