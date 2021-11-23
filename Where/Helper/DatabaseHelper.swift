//
//  DatabaseHelper.swift
//  Where
//
//  Created by Vinicius Silva on 23/11/21.
//

import Foundation
import CoreData
import CoreLocation

class DatabaseHelper {
    static let shared = DatabaseHelper()
    
    private let persistentContainer: NSPersistentContainer
    
    private init () {
        self.persistentContainer = NSPersistentContainer(name: "Where")
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error \(error.localizedDescription)")
            }
        }
    }
    
    func saveWorkout(workout: Workout) {
        let context = self.persistentContainer.viewContext
        let activity = Activity(context: context)
        
        let locations = workout.route.map({(cllocation: CLLocationCoordinate2D) -> Location in
            let location = Location(context: context)
            location.latitude = cllocation.latitude
            location.longitude = cllocation.longitude
            
            return location
        })
        
        activity.locations = NSOrderedSet(array: locations)
        activity.date = Date()
        activity.distance = workout.discante
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getAllActivities() -> [Activity] {
        let context = self.persistentContainer.viewContext
        let request = Activity.fetchRequest()
        
        var result: [Activity] = []
        
        do {
            result = try context.fetch(request)
        } catch {
            print(error.localizedDescription)
        }
        
        return result
    }
}
