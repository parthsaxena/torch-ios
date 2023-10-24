//
//  PlaceSensorViewControllerBridge.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/6/23.
//

import Foundation
import GoogleMaps
import GoogleMapsUtils
import SwiftUI

struct PlaceSensorViewControllerBridge: UIViewControllerRepresentable {

//    var pin: GMSMarker
    @Binding var mapBottomOffset: CGFloat
    @Binding var isConfirmingLocation: Bool
  @Binding var markers: [GMSMarker]
//    @State var pin: GMSMarker
  @Binding var selectedMarker: GMSMarker?
    @Binding var selectedDetector: Detector?
    @Binding var showDetectorDetails: Bool
  var detectors: [Detector]
  var onAnimationEnded: () -> ()
  var mapViewWillMove: (Bool) -> ()
    var mapViewDidChange: (GMSCameraPosition) -> ()
    
    var clusterManager: GMUClusterManager!

  func makeUIViewController(context: Context) -> PlaceSensorMapViewController {
    let uiViewController = PlaceSensorMapViewController()
    uiViewController.map.delegate = context.coordinator
      
//      uiViewController.pin = pin
      uiViewController.markers = markers
    return uiViewController
  }

  func updateUIViewController(_ uiViewController: PlaceSensorMapViewController, context: Context) {
//      uiViewController.clusterManager.add(markers)
      
      // print("bridge: \(self.markers)")
    markers.forEach {
        if let userData = $0.userData as? String {
            if userData != "remove" {
                $0.map = uiViewController.map
            }
        } else {
            $0.map = uiViewController.map
        }
    }
      
      uiViewController.map.isUserInteractionEnabled = !isConfirmingLocation
      
//      if isConfirmingLocation {
      uiViewController.map.padding = UIEdgeInsets(top: 0, left: 0, bottom: mapBottomOffset, right: 0)
//      }
      
//    selectedMarker?.map = uiViewController.map
//    animateToSelectedMarker(viewController: uiViewController)
//      self.pin.map = uiViewController.map
      
    // print("update")
  }

  func makeCoordinator() -> MapViewCoordinator {
    return MapViewCoordinator(self)
  }

  private func animateToSelectedMarker(viewController: PlaceSensorMapViewController) {
    // print("animate to marker")
      
    guard let selectedMarker = selectedMarker else {
      return
    }

    let map = viewController.map
    if map.selectedMarker != selectedMarker {
      map.selectedMarker = selectedMarker
        
        DispatchQueue.main.async {
          map.animate(with: GMSCameraUpdate.setTarget(selectedMarker.position))
          DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            map.animate(toZoom: 15)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
              onAnimationEnded()
            })
          })
        }
    }
  }
    
    func selectDetector(marker: GMSMarker) {
        // print("select detector \(detectors.count)")
        // print("seletedd marker \(marker)")
        
        guard let id = marker.userData as? String else {
            return
        }
        
        selectedMarker = marker
        selectedDetector = detectors.first(where: { detector in
            detector.id == id
        })!
        showDetectorDetails = true
    }

  final class MapViewCoordinator: NSObject, GMSMapViewDelegate {
    var mapViewControllerBridge: PlaceSensorViewControllerBridge

    init(_ mapViewControllerBridge: PlaceSensorViewControllerBridge) {
      self.mapViewControllerBridge = mapViewControllerBridge
    }

    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
      self.mapViewControllerBridge.mapViewWillMove(gesture)
    }
      
      func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
          //
          // print("updating map")
//          self.pin?.position = position.target
          self.mapViewControllerBridge.mapViewDidChange(position)
      }
      
      func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {          
          mapViewControllerBridge.selectDetector(marker: marker)
          return true
    }
      
  }
}
