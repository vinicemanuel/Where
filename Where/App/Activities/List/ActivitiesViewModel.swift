//
//  ActivitiesViewModel.swift
//  Where
//
//  Created by Vinicius Silva on 04/03/22.
//

import Foundation

protocol ActivitiesViewModelDelegate {
    var activities: [Activity] { get }
    func deleteActicity(activity: Activity) -> Bool
}

class ActivitiesViewModel: ActivitiesViewModelDelegate {
    private let databaseManager: DatabaseDelegate
    
    init(databaseManager: DatabaseDelegate = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    //MARK: - ActivitiesViewModelDelegate
    func deleteActicity(activity: Activity) -> Bool {
        let deleted = self.databaseManager.delete(activity: activity)
        return deleted
    }
    
    var activities: [Activity] {
        get {
            return DatabaseManager.shared.getAllActivities()
        }
    }
}
