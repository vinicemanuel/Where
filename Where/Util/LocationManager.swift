//
//  LocationManager.swift
//  Where
//
//  Created by Vinicius Silva on 16/11/21.
//

import Foundation
import CoreLocation

class LocationManager {
    static let shared = ()
    
    private init() {
        self.shared.desiredAccuracy = kCLLocationAccuracyBest
    }
}
