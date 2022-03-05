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
        self.timer = Timer(timeInterval: 1, repeats: true, block: { _ in
            self.passthroughLocations.send([CLLocation(latitude: 0, longitude: 0)])
        })
        
        RunLoop.main.add(self.timer!, forMode: .default)
    }
    
    func stopUpdate() {
        if let timer = timer {
            timer.invalidate()
        }
    }
    
    func subscribeForUpdates() -> AnyPublisher<[CLLocation], Never> {
        return self.passthroughLocations.eraseToAnyPublisher()
    }
}
