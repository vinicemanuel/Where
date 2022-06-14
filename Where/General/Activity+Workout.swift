//
//  Activity+Workout.swift
//  Where
//
//  Created by vinicius emanuel on 13/06/22.
//

import Foundation
import CoreLocation

extension Activity {
    func convertToWorkout() -> Workout {
        let workout = Workout()
        
        guard let locations: NSOrderedSet = self.locations,
        let locationsArray = locations.array as? [Location] else {
            return workout
        }
        
        let workoutRoute = locationsArray.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
        workout.route = workoutRoute
        
        return workout
    }
}
