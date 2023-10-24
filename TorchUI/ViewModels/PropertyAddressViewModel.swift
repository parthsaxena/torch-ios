//
//  PropertyAddressViewModel.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/10/23.
//

import Foundation
import MapKit
import Contacts

class PropertyAddressViewModel: NSObject, ObservableObject {
    
    @Published private(set) var results: Array<SearchResult> = []
    @Published var searchableText = ""

    private lazy var localSearchCompleter: MKLocalSearchCompleter = {
        let completer = MKLocalSearchCompleter()
        completer.delegate = self
//        completer.
        return completer
    }()
    
    func searchAddress(_ searchableText: String) {
        guard searchableText.isEmpty == false else { return }
                
        localSearchCompleter.queryFragment = searchableText
        
//        let searchRequest = MKLocalSearch.Request()
//        searchRequest.naturalLanguageQuery = searchableText
////        searchRequest.region = .
//        let search = MKLocalSearch(request: searchRequest)
//        search.start { (response, error) in
//            guard let response = response else {
//                // Handle the error.
//                // print("MKLocalSearch error: \(error)")
//                return
//            }
//
//
//            for item in response.mapItems {
////                item.placemark.postalAddress
//            }
//
//            self.results = response.mapItems.map {
//                let addy = "\($0.placemark.postalAddress!.street), \($0.placemark.postalAddress!.city), \($0.placemark.postalAddress!.state) \($0.placemark.postalAddress!.postalCode)"
////                // print(addy)
//                return SearchResult(address: addy)
//            }
////            self.results = Array(self.results[0..<min(self.results.count, 6)])
//        }
    }
}

extension PropertyAddressViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        Task { @MainActor in
//            completer.res
//            var tmp: [SearchResult] = []
//            for result in completer.results {
//                let returnedAddy = "\(result.title), \(result.subtitle)"
//                CLGeocoder().geocodeAddressString(returnedAddy) { placemarks, err in
//                    if err != nil {
//                        // print("clgeocoder error: \(err); \(returnedAddy)")
//                        tmp.append(SearchResult(address: returnedAddy))
//                    } else {
//                        let placemark = placemarks![0]
//
//                        let addy = "\(placemark.postalAddress!.street), \(placemark.postalAddress!.city), \(placemark.postalAddress!.state) \(placemark.postalAddress!.postalCode)"
//                        tmp.append(SearchResult(address: addy))
//                    }
//                }
//            }
            
            self.results = completer.results.map {
                var rawDescription = "\($0.title), \($0.subtitle)"
                rawDescription = rawDescription.replacingOccurrences(of: "United States", with: "US")
                return SearchResult(address: rawDescription)
            }
            
//            // print("got results: \(self.results.count)")
            
            self.results.removeAll { result in
                return result.address.contains("Search Nearby")
            }
            
//            // print("after removal: \(self.results.count)")
            
            self.results = Array(results[0..<min(results.count, 6)])
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // print(error)
    }
}
