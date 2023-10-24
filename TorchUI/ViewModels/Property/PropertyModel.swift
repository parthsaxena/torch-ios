//
//  PropertyModel.swift
//  TorchUI
//
//  Created by Parth Saxena on 6/28/23.
//

import Foundation
import GoogleMaps

struct Property: Hashable, Identifiable, Equatable {
    var id: String
    
    var propertyName: String
    var propertyAddress: String
    var propertyImage: String
    
    var coordinate: CLLocationCoordinate2D?
    var detectors: [Detector] = []
    var threat: Threat = Threat.Green
    
    var propertyDescription: String = ""        
}

struct SearchResult: Hashable, Identifiable {
    let id = UUID()
    
    let address: String
}
