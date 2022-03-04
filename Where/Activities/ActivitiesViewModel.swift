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
    //MARK: - ActivitiesViewModelProtocol
    func deleteActicity(activity: Activity) -> Bool {
        let deleted = DatabaseManager.shared.delete(activity: activity)
        return deleted
    }
    
    var activities: [Activity] {
        get {
            return DatabaseManager.shared.getAllActivities()
        }
    }
}
