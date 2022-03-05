//
//  ActivitiesViewModel.swift
//  Where
//
//  Created by Vinicius Silva on 04/03/22.
//

import Foundation

protocol ActivitiesViewModelProtocol {
    var activities: [Activity] { get }
    func deleteActicity(activity: Activity) -> Bool
}

class ActivitiesViewModel: ActivitiesViewModelProtocol {
    private let databaseManager: DatabaseProtocol
    
    init(databaseManager: DatabaseProtocol = DatabaseManager.shared) {
        self.databaseManager = databaseManager
    }
    
    //MARK: - ActivitiesViewModelProtocol
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
