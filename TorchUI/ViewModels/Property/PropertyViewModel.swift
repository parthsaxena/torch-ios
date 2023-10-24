//
//  PropertyViewModel.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/6/23.
//

import Foundation

class PropertyViewModel: ObservableObject {
    var property: Property?
    
    init(property: Property) {
        self.property = property
    }
}
