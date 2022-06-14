//
//  Fake_AuthorizationManager.swift
//  WhereTests
//
//  Created by Vinicius Silva on 05/03/22.
//

import Foundation
@testable import Where

class Fake_AuthorizationManager: AuthorizationDelegate {
    
    //MARK: - AuthorizationProtocol
    func requestLocationAuthorization() {
        
    }
    
    func deviceLocationIsAuthorized() -> Bool {
        true
    }
}
