//
//  ActivityCellViewModelTest.swift
//  WhereTests
//
//  Created by Vinicius Silva on 05/03/22.
//

import XCTest
import CoreLocation
@testable import Where

class ActivityCellViewModelTest: XCTestCase {
    
    lazy var workout: Workout = {
        let workout = Workout()
        
        workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 0, longitude: 1))
        workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 1, longitude: 0))
        workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 0, longitude: 2))
        workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 2, longitude: 0))
        
        return workout
    }()
    
    lazy var date: Date = {
        var dateComponents = DateComponents()
        dateComponents.year = 1980
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.hour = 8
        dateComponents.minute = 34

        // Create date from components
        let userCalendar = Calendar.current
        let someDateTime = userCalendar.date(from: dateComponents)
        return someDateTime!
    }()

    override func setUpWithError() throws {
        DatabaseManager.shared.saveWorkout(workout: self.workout, date: self.date)
    }

    override func tearDownWithError() throws {
        let activity = DatabaseManager.shared.getAllActivities().last!
        let _ = DatabaseManager.shared.delete(activity: activity)
    }
    
    func test_components() {
        let activity = DatabaseManager.shared.getAllActivities().last!
        let viewModel = ActivityCellViewModel(activity: activity)
        
        XCTAssertEqual(viewModel.dateString, "11/07/1980 08:34")
        XCTAssertEqual(viewModel.distanceString, "719.25 Km")
        XCTAssertEqual(viewModel.straightDistance, 313783.52481117623)
        XCTAssertEqual(viewModel.center.latitude, 1)
        XCTAssertEqual(viewModel.center.longitude, 1)
    }

}
