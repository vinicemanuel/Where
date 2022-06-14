//
//  Fake_DatabaseManager.swift
//  WhereTests
//
//  Created by Vinicius Silva on 05/03/22.
//

import Foundation
import CoreLocation
@testable import Where

class Fake_DatabaseManager: DatabaseDelegate {
    var workouts: [Workout] = []
    
    //MARK: - DatabaseProtocol
    func saveWorkout(workout: Workout, date: Date) {
        workouts.append(workout)
    }
    
    func getAllActivities() -> [Activity] {
        return []
    }
    
    func delete(activity: Activity) -> Bool {
        true
    }
}
