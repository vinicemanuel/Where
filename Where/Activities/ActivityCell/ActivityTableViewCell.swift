//
//  ActivityTableViewCell.swift
//  Where
//
//  Created by Vinicius Silva on 09/11/21.
//

import UIKit
import MapKit

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
