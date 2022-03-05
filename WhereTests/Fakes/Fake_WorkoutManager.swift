//
//  Fake_WorkoutManager.swift
//  WhereTests
//
//  Created by Vinicius Silva on 05/03/22.
//

import Foundation
import CoreLocation
import Combine
@testable import Where

class Fake_WorkoutManager: WorkoutProtocol {
    
    private let passthroughLocations = PassthroughSubject<[CLLocation], Never>()
    var timer: Timer?
    
    //MARK: WorkoutProtocol
    func startUpdate() {
        self.passthroughLocations.send([CLLocation(latitude: 0, longitude: 0)])
    }
    
    func stopUpdate() {
        
    }
    
    func subscribeForUpdates() -> AnyPublisher<[CLLocation], Never> {
        return self.passthroughLocations.eraseToAnyPublisher()
    }
}
