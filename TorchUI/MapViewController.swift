//
//  MapViewController.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/6/23.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils
import UIKit

class MapViewController: UIViewController, GMSMapViewDelegate {

  var map =  GMSMapView(frame: .zero)
    var clusterManager: GMUClusterManager!
  var isAnimating: Bool = false
    var markers: [GMSMarker] = []
    let MapStyle = "[   {     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#f5f5f5\"       }     ]   },   {     \"elementType\": \"labels.icon\",     \"stylers\": [       {         \"visibility\": \"off\"       }     ]   },   {     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#616161\"       }     ]   },   {     \"elementType\": \"labels.text.stroke\",     \"stylers\": [       {         \"color\": \"#f5f5f5\"       }     ]   },   {     \"featureType\": \"administrative.land_parcel\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#bdbdbd\"       }     ]   },   {     \"featureType\": \"poi\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#eeeeee\"       }     ]   },   {     \"featureType\": \"poi\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#757575\"       }     ]   },   {     \"featureType\": \"poi.park\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#e5e5e5\"       }     ]   },   {     \"featureType\": \"poi.park\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#9e9e9e\"       }     ]   },   {     \"featureType\": \"road\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#ffffff\"       }     ]   },   {     \"featureType\": \"road.arterial\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#757575\"       }     ]   },   {     \"featureType\": \"road.highway\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#dadada\"       }     ]   },   {     \"featureType\": \"road.highway\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#616161\"       }     ]   },   {     \"featureType\": \"road.local\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#9e9e9e\"       }     ]   },   {     \"featureType\": \"transit.line\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#e5e5e5\"       }     ]   },   {     \"featureType\": \"transit.station\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#eeeeee\"       }     ]   },   {     \"featureType\": \"water\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#c9c9c9\"       }     ]   },   {     \"featureType\": \"water\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#9e9e9e\"       }     ]   } ]"

  override func loadView() {
    super.loadView()
//      self.map = GMSMapView(frame: .zero, camera: GMSCameraPosition(
//        latitude: -33.8683,
//        longitude: 151.2086,
//        zoom: 16
//      ))
    self.map.mapType = .terrain
//    self.map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
//      do {
//            // Set the map style by passing a valid JSON string.
//          if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
//              self.map.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//              // print("set map style")
//            } else {
//              // print("Unable to find style.json")
//            }
//      } catch {
//        // print("One or more of the map styles failed to load. \(error)")
//      }
      
      self.view = map
      
    let iconGenerator = GMUDefaultClusterIconGenerator()
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let renderer = GMUDefaultClusterRenderer(mapView: map,
                              clusterIconGenerator: iconGenerator)
    clusterManager = GMUClusterManager(map: map, algorithm: algorithm,
                                                    renderer: renderer)
      clusterManager.add(markers)
  }
    
  
}
