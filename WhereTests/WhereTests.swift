//
//  WhereTests.swift
//  WhereTests
//
//  Created by Vinicius Silva on 08/11/21.
//

import XCTest
import CoreLocation
@testable import Where

class Test_Workout: XCTestCase {
    
    var workout: Workout!

    override func setUpWithError() throws {
        self.workout = Workout()
    }

    override func tearDownWithError() throws {
        self.workout = nil
    }

    func test_updateWithNextLocation_firstLocation() throws {
        self.workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 0, longitude: 1))
        
        XCTAssertEqual(self.workout.discante, 0)
        XCTAssertEqual(self.workout.route.count, 1)
        XCTAssertEqual(self.workout.route.first?.latitude, 0)
        XCTAssertEqual(self.workout.route.first?.longitude, 1)
    }
    
    func test_updateWithNextLocation_towOrMoreLocations() throws {
        self.workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 0, longitude: 0))
        self.workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 0, longitude: -1))
        
        XCTAssertGreaterThan(self.workout.discante, 0)//km
        XCTAssertEqual(self.workout.route.count, 2)
    }
    
    func test_clear() {
        self.workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 0, longitude: 0))
        self.workout.updateWithNextLocation(nextLocation: CLLocation(latitude: 0, longitude: -1))
        
        self.workout.clear()
        
        XCTAssertEqual(self.workout.route.count, 0)
        XCTAssertEqual(self.workout.discante, 0)
    }
}
