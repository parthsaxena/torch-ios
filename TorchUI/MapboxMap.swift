//
//  MapboxMap.swift
//  TorchUI
//
//  Created by Parth Saxena on 9/20/23.
//

import Foundation
import SwiftUI
import MapboxMaps

extension UIImage
{
    func scale(newWidth: CGFloat) -> UIImage
    {
        guard self.size.width != newWidth else{return self}
        
        let scaleFactor = newWidth / self.size.width
        
        let newHeight = self.size.height * scaleFactor
        let newSize = CGSize(width: newWidth, height: newHeight)
        
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0.0)
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        return newImage ?? self
    }
}

struct MapboxMap: UIViewRepresentable {
    

    @Binding var zoomLevel: CGFloat
    @ObservedObject var sessionManager = SessionManager.shared
    var mapView: MapView = MapView(frame: .zero, mapInitOptions: MapInitOptions(resourceOptions: ResourceOptions(accessToken: "pk.eyJ1IjoidnRyZW1zaW4iLCJhIjoiY2xsNzE0M2lmMGd0eTNnazRjM2s3MndvZCJ9.z9GP9XylmH4RKR-swu14nA")))
    
    func makeUIView(context: Context) -> MapView {
//        let options = MapInitOptions(resourceOptions: ResourceOptions(accessToken: "pk.eyJ1IjoidnRyZW1zaW4iLCJhIjoiY2xsNzE0M2lmMGd0eTNnazRjM2s3MndvZCJ9.z9GP9XylmH4RKR-swu14nA"))
        let cameraOptions = CameraOptions(center: sessionManager.selectedProperty!.coordinate!, zoom: zoomLevel, bearing: 0.0, pitch: 0.0)
//        let options = MapInitOptions(cameraOptions: cameraOptions, styleURI: StyleURI(rawValue: "mapbox://styles/vtremsin/cllujjy2n00ak01r7abqo8tcb"))
        let options = MapInitOptions(resourceOptions: ResourceOptions(accessToken: "pk.eyJ1IjoidnRyZW1zaW4iLCJhIjoiY2xsNzE0M2lmMGd0eTNnazRjM2s3MndvZCJ9.z9GP9XylmH4RKR-swu14nA"), cameraOptions: cameraOptions)
//        let options = MapInitOptions(cameraOptions: cameraOptions, styleURI: StyleURI.outdoors)
        var mapView = MapView(frame: .zero, mapInitOptions: options)
//        mapView.mapboxMap.loadStyleJSON(jsonString)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        var pointAnnotationManager = mapView.annotations.makePointAnnotationManager()
        
        // iterate over selected property's detectors
        for detector in sessionManager.selectedProperty!.detectors {
            var pointAnnotation = PointAnnotation(coordinate: detector.coordinate!)
            var annotationIcon = "DetectorIcons/\(detector.sensorIdx!)"
            if detector.threat == Threat.Red {
                annotationIcon = "DetectorIcons/ThreatRed"
            } else if detector.threat == Threat.Yellow {
                annotationIcon = "DetectorIcons/ThreatYellow"
            }
            
            var annotationImage = UIImage(named: annotationIcon)!
            annotationImage.scale(newWidth: 1.0)
            pointAnnotation.image = .init(image: annotationImage, name: annotationIcon)
//            pointAnnotation.image?.image.scale = 4.0
            pointAnnotation.iconAnchor = .bottom
            pointAnnotation.iconSize = 0.25
            
            pointAnnotationManager.annotations.append(pointAnnotation)
        }
        
        // Build property icon view
        let width = max(80, SessionManager.shared.selectedProperty!.propertyName.count * 12 + 25)
        let viewFromXib = Bundle.main.loadNibNamed("PropertyIconView", owner: self, options: nil)![0] as! PropertyIconView
        viewFromXib.frame = CGRect(x: 0, y: 0, width: width, height: 50)

        viewFromXib.propertyImageView.layer.shadowColor = UIColor.black.cgColor
        viewFromXib.propertyImageView.layer.shadowOpacity = 0.2
        viewFromXib.propertyImageView.layer.shadowOffset = .zero
        viewFromXib.propertyImageView.layer.shadowRadius = 4

        let rectShape = CAShapeLayer()
        rectShape.bounds = viewFromXib.frame
        rectShape.position = viewFromXib.center
        rectShape.path = UIBezierPath(roundedRect: CGRectMake(0, 0, CGFloat(width - 30), viewFromXib.propertyMainView.bounds.height), byRoundingCorners: [.topRight, .bottomRight], cornerRadii: CGSize(width: 50, height: 50)).cgPath


        viewFromXib.propertyMainView.layer.mask = rectShape
        viewFromXib.propertyLabel.text = SessionManager.shared.selectedProperty!.propertyName
        viewFromXib.propertyLabel.textColor = UIColor(cgColor: CustomColors.TorchGreen.cgColor!)
        viewFromXib.propertyMainView.backgroundColor = UIColor.white
        
        let propertyAnnotationOptions = ViewAnnotationOptions(
            geometry: Point(sessionManager.selectedProperty!.coordinate!),
            width: CGFloat(max(80, SessionManager.shared.selectedProperty!.propertyName.count * 12 + 25)),
            height: 50,
            allowOverlap: false,
            anchor: .center
        )
        try? mapView.viewAnnotations.add(viewFromXib, options: propertyAnnotationOptions)
        
//        pointAnnotationManager.delegate = AnnotationInteractionDelegate(
        
        return mapView
    }
    
    func updateUIView(_ uiView: MapboxMaps.MapView, context: Context) {
        let cameraOptions = CameraOptions(zoom: zoomLevel, bearing: 0.0, pitch: 0.0)
        uiView.camera.fly(to: cameraOptions, duration: 0.1)
    }
}
