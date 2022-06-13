//
//  ActivityDetailViewModelDelegate.swift
//  Where
//
//  Created by vinicius emanuel on 13/06/22.
//

import CoreLocation

protocol ActivityDetailViewModelDelegate {
    var dateString: String { get }
    var distanceString: String { get }
    var straightDistance: CLLocationDistance { get }
    var center: CLLocationCoordinate2D { get }
    var overlay: CustonPolyline { get }
}
