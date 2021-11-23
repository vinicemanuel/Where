//
//  Workout .swift
//  Where
//
//  Created by Vinicius Silva on 18/11/21.
//

import Foundation
import CoreLocation

class Workout {
    var discante: Double = 0
    var route: [CLLocationCoordinate2D] = []
    private var lastLocation: CLLocation?
    
    func updateWithNextLocation(nextLocation location: CLLocation) {
        guard let lastLocation = self.lastLocation else {
            self.lastLocation = location
            return
        }

        print(self.discante)
        self.discante += (lastLocation.distance(from: location) / 1000.0)
        self.route.append(location.coordinate)
    }
    
    func clear() {
        self.route = []
        self.discante = 0
        self.lastLocation = nil
    }
}
