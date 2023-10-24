////
////  PropertyAddressViewModel.swift
////  TorchUI
////
////  Created by Parth Saxena on 7/10/23.
////
//
//import Foundation
//import MapKit
//import Contacts
//
//class PropertyPhotoViewModel: NSObject, ObservableObject {
//    
//    @Published private(set) var results: Array<SearchResult> = []
//    @Published var searchableText = ""
//
//    private lazy var localSearchCompleter: MKLocalSearchCompleter = {
//        let completer = MKLocalSearchCompleter()
//        completer.delegate = self
//        return completer
//    }()
//    
//    func searchAddress(_ searchableText: String) {
//        guard searchableText.isEmpty == false else { return }
//                
//        localSearchCompleter.queryFragment = searchableText
//    }
//}
