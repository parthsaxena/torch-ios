//
//  PlaceSensorMapViewController.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/6/23.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils
import UIKit
import CoreLocation

class PlaceSensorMapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    var currentLocation: CLLocation?
    
  let map =  GMSMapView(frame: .zero)
    var clusterManager: GMUClusterManager!
  var isAnimating: Bool = false
    var markers: [GMSMarker] = []
    let MapStyle = "[   {     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#f5f5f5\"       }     ]   },   {     \"elementType\": \"labels.icon\",     \"stylers\": [       {         \"visibility\": \"off\"       }     ]   },   {     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#616161\"       }     ]   },   {     \"elementType\": \"labels.text.stroke\",     \"stylers\": [       {         \"color\": \"#f5f5f5\"       }     ]   },   {     \"featureType\": \"administrative.land_parcel\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#bdbdbd\"       }     ]   },   {     \"featureType\": \"poi\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#eeeeee\"       }     ]   },   {     \"featureType\": \"poi\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#757575\"       }     ]   },   {     \"featureType\": \"poi.park\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#e5e5e5\"       }     ]   },   {     \"featureType\": \"poi.park\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#9e9e9e\"       }     ]   },   {     \"featureType\": \"road\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#ffffff\"       }     ]   },   {     \"featureType\": \"road.arterial\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#757575\"       }     ]   },   {     \"featureType\": \"road.highway\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#dadada\"       }     ]   },   {     \"featureType\": \"road.highway\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#616161\"       }     ]   },   {     \"featureType\": \"road.local\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#9e9e9e\"       }     ]   },   {     \"featureType\": \"transit.line\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#e5e5e5\"       }     ]   },   {     \"featureType\": \"transit.station\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#eeeeee\"       }     ]   },   {     \"featureType\": \"water\",     \"elementType\": \"geometry\",     \"stylers\": [       {         \"color\": \"#c9c9c9\"       }     ]   },   {     \"featureType\": \"water\",     \"elementType\": \"labels.text.fill\",     \"stylers\": [       {         \"color\": \"#9e9e9e\"       }     ]   } ]"

  override func loadView() {
    super.loadView()
      self.map.mapType = .terrain
      self.map.isBuildingsEnabled = true
//      self.map.mapStyle = GMSMapStyle
      self.map.isMyLocationEnabled = true
//      self.map.padding = UIEdgeInsets(top: 0, left: 0, bottom: 300, right: 0)
//      self.map.delegate = self
      
      self.view = map
//      self.pin.map = self.map      
      
    let iconGenerator = GMUDefaultClusterIconGenerator()
    let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
    let renderer = GMUDefaultClusterRenderer(mapView: map,
                              clusterIconGenerator: iconGenerator)
    clusterManager = GMUClusterManager(map: map, algorithm: algorithm,
                                                    renderer: renderer)
      clusterManager.add(markers)
      
      locationManager = CLLocationManager()
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.requestWhenInUseAuthorization()
      locationManager.startUpdatingLocation()
      locationManager.delegate = self
  }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
            // print("Location: \(location)")

//        let zoomLevel = 15.0
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude,
                                              zoom: 15.0)
        
        self.map.animate(to: camera)
        
        locationManager.stopUpdatingLocation()
        
    }
    
//    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//        //
//        // print("updating map")
//        self.pin?.position = position.target
//    }
  
}
