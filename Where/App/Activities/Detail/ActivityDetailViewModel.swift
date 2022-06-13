//
//  ActivityDetailViewModel.swift
//  Where
//
//  Created by vinicius emanuel on 13/06/22.
//

import Foundation

protocol ActivityDetailViewDelegate: MapViewOlderRouteDelegate {
    func deleteActicity(activity: Activity) -> Bool
}

class ActivityDetailViewModel: ActivityViewModel, ActivityDetailViewDelegate {
    
    private let databaseManager: DatabaseDelegate
    
    init(activity: Activity, databaseManager: DatabaseDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
        super.init(activity: activity)
    }

    
    //MARK: - MapViewOlderRouteDelegate
    func getOldRouteOverlay() -> [CustonPolyline] {
        let activities = self.databaseManager.getAllActivities()
        let workouts = activities.map( { $0.convertToWorkout() } )
        let overlays = workouts.map( { $0.convertToPolylineOveraly() } )
        
        return overlays
    }
    
    //MARK: - ActivityDetailViewDelegate
    func deleteActicity(activity: Activity) -> Bool {
        let deleted = self.databaseManager.delete(activity: activity)
        return deleted
    }
}
