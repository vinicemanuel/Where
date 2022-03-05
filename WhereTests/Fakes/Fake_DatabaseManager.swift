//
//  Fake_DatabaseManager.swift
//  WhereTests
//
//  Created by Vinicius Silva on 05/03/22.
//

import Foundation
import CoreLocation
@testable import Where

class Fake_DatabaseManager: DatabaseProtocol {
    
    //MARK: - DatabaseProtocol
    func saveWorkout(workout: Workout) {
        
    }
    
    func getAllActivities() -> [Activity] {
        []
    }
    
    func delete(activity: Activity) -> Bool {
        true
    }
}
