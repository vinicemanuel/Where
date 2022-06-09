//
//  RecordViewModelTests.swift
//  WhereTests
//
//  Created by Vinicius Silva on 05/03/22.
//

import XCTest
import CoreLocation
@testable import Where

class RecordViewModelTests: XCTestCase {
    
    let fakeWorkoutManager = Fake_WorkoutManager()
    let fakeDatabaseManager = Fake_DatabaseManager()
    let fakeAuthorizationManager = Fake_AuthorizationManager()
    
    lazy var viewModel = RecordViewModel(workoutManager: self.fakeWorkoutManager,
                                    databaseManager: self.fakeDatabaseManager,
                                    authorizationManager: self.fakeAuthorizationManager)

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        self.viewModel.stopRecordWorkout()
        self.viewModel.discartCurrentWorkout()
    }

    func test_startRecordWorkout() {
        let expectation = expectation(description: "wait for get first location")
        var receivedLocations: [CLLocation] = []
        
        self.viewModel.configSubscriptionForLocationsUpdate { locations in
            receivedLocations = locations
            expectation.fulfill()
        }
        
        viewModel.startRecordWorkout()
        
        XCTAssertEqual(receivedLocations.count, 1)
        waitForExpectations(timeout: 10)
    }
    
    func test_saveCurrentWorkout() {
        let expectation = expectation(description: "wait for get first location")
        
        self.viewModel.configSubscriptionForLocationsUpdate { [unowned self] locations in
            self.viewModel.saveCurrentWorkout()
            expectation.fulfill()
        }
        
        viewModel.startRecordWorkout()
        XCTAssertEqual(fakeDatabaseManager.workouts.count, 1)
        waitForExpectations(timeout: 10)
    }
    
    func test_getCurrentRouteOverlay() {
        let expectation = expectation(description: "wait for get first location")
        var polyline: CustonPolyline?
        
        self.viewModel.configSubscriptionForLocationsUpdate { [unowned self] locations in
            polyline = self.viewModel.getCurrentRouteOverlay()
            expectation.fulfill()
        }
        
        viewModel.startRecordWorkout()
        XCTAssertNotNil(polyline)
        waitForExpectations(timeout: 10)
    }
}
