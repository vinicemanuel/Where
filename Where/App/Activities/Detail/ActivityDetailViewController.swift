//
//  ActivityDetailViewController.swift
//  Where
//
//  Created by vinicius emanuel on 10/06/22.
//

import UIKit
import MapKit

class ActivityDetailViewController: UIViewController {

    @IBOutlet weak var deleteActivity: UIButton!
    @IBOutlet weak var mapActivities: MKMapView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func deleteActivityTaped(_ sender: Any) {
    }
}
