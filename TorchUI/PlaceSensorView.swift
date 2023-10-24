//
//  PlaceSensorView.swift
//  TorchUI
//
//  Created by Parth Saxena on 6/28/23.
//

import SwiftUI
import CoreLocation
import GoogleMaps
import CodeScanner
import MapboxMaps

struct PlaceSensorView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    
//    @ObservedObject var sessionManager = SessionManager()
//    @Binding var state: OnboardingState?
    @ObservedObject var sessionManager = SessionManager.shared
    
    // Google maps tutorial START
    static var detectors: [Detector] = []
    @State var markers: [GMSMarker] = []
    
    @State var annotations: [PointAnnotation] = [PointAnnotation]()
    
    @State var hideOverlay: Bool = false
    @State var showDetectorDetails: Bool = false
    @State var zoomInCenter: Bool = false
    @State var selectedDetector: Detector?
    @State var selectedMarker: GMSMarker?
    
    @State var isPresentingScanner: Bool = false
    @State var showingOptions: Bool = false
    
    @State var isConfirmingLocation: Bool = false
    
    @State var selectedSensor: Detector?
    
//    @State var mapBottomOffset: CGFloat = 0.0
    @State var size: CGSize = CGSize()
    
    @State var pin: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    @State var needsLocationPin: Bool = false
    
    @State var moveToUserTapped: Bool = false
    
    @State var sensorTapped: Bool = false
    
    // Google maps tutorial END
    
    init() {
        // print("Count: \(sessionManager.selectedProperty!.detectors.count)")
        // print("Markers Count: \(markers.count)")
         
//        self.pin = GMSMarker()
////        pin!.icon = UIImage(named: "Pin")
////        pin!.icon?.scale = 5.0
//
//        var markerImage = UIImage(named: "Pin")
//        markerImage = UIImage(cgImage: (markerImage?.cgImage)!, scale: 4.0, orientation: (markerImage?.imageOrientation)!)
//        self.pin!.icon = markerImage
//        pin!.map = self.map
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Maps
                ZStack {
                    MapboxPlaceSensorViewWrapper(showDetectorDetails: $showDetectorDetails, selectedDetector: $selectedDetector, needsLocationPin: $needsLocationPin, annotations: $annotations, pin: $pin, moveToUserTapped: $moveToUserTapped, sensorTapped: $sensorTapped)
//                    PlaceSensorViewControllerBridge(mapBottomOffset: $size.height, isConfirmingLocation: $isConfirmingLocation, markers: $markers, selectedMarker: $selectedMarker, selectedDetector: $selectedDetector, showDetectorDetails: $showDetectorDetails, detectors: sessionManager.selectedProperty!.detectors, onAnimationEnded: {
//                        self.zoomInCenter = true
//                    }, mapViewWillMove: { (isGesture) in
//                        guard isGesture else { return }
//                        self.zoomInCenter = false
//                    }, mapViewDidChange: { (position) in
//                        if !isConfirmingLocation {
//                            self.pin = position.target
//                            // print("Map did change: \(position.target)")
//                            // print("Map did change, pin: \(self.pin)")
//                        }
//                    })
                    .ignoresSafeArea()
                    .animation(.easeIn)
                }
                
//                ZStack {
//                    VStack {
//                        Spacer()
//
//                        Image("Pin")
//                            .resizable()
//                            .frame(width: 60, height: 69)
//                            .padding(.bottom, 69 + 20)
//
//                        Spacer()
//                    }
//                    .padding(.bottom, self.size.height)
//                }
                
                VStack {
                    // Image pin
                    
                    Spacer()
                    
                    // Overlay
                    VStack {
                        if isConfirmingLocation {
                            SensorConfirmLocationOverlayView(size: $size, markers: $markers, pin: $pin, selectedSensor: $selectedSensor, isConfirmingLocation: $isConfirmingLocation)
                        } else {
                            SensorSetupOverlayView(size: $size, markers: $markers, sessionManager: sessionManager, isPresentingScanner: $isPresentingScanner, isConfirmingLocation: $isConfirmingLocation, selectedSensor: $selectedSensor, selectedDetector: $selectedDetector, sensorTapped: $sensorTapped, annotations: $annotations, pin: $pin)
                                .sheet(isPresented: $isPresentingScanner) {
                                    VStack {
                                        HStack {
                                            Spacer()
                                            
                                            Text("Scan the QR code on your Torch device")
                                                .font(Font.custom("Manrope-Medium", fixedSize: 20))
                                                .foregroundColor(CustomColors.TorchGreen)
                                                .padding(.top, 20)
                                            
                                            Spacer()
                                        }
                                        
                                        CodeScannerView(codeTypes: [.qr], showViewfinder: true) { response in
                                            if case let .success(result) = response {
                                                let impactMed = UIImpactFeedbackGenerator(style: .heavy)
                                                impactMed.impactOccurred()
                                                
                                                // print("Got device EUI: \(result.string)")
                                                isPresentingScanner = false
                                                
                                                // create detector model
                                                var detector = Detector(id: result.string, deviceName: String(sessionManager.newProperty!.detectors.count + 1), deviceBattery: 0.0, coordinate: nil, selected: true, sensorIdx: sessionManager.newProperty!.detectors.count + 1)
                                                sessionManager.addNewDetector(detector: detector)
                                                self.selectedSensor = detector
                                                self.selectedDetector = detector
                                                needsLocationPin = true
                                                // sessionManager.newProperty!.detectors.append(detector)
                                                
                                                let x =  print("Added, new detector count: \(sessionManager.newProperty!.detectors.count)")
                                            }
                                        }
                                        .ignoresSafeArea(.container)
                                    }
                                }
                        }
                    }
                    .animation(.easeInOut)
                }
                
                // Heading saying Set up torch sensors
                HStack {
                    Spacer()
                    
                    Text("Set up Torch sensors")
                        .font(Font.custom("Manrope-SemiBold", fixedSize: 20))
                        .foregroundColor(CustomColors.TorchGreen)
                        .padding(.top, 25)
                    
                    Spacer()
                }
                
                // Exit, layers, location button on right side
                HStack {
                    Spacer()
                    VStack(spacing: 1) {
                        ExitButton(showingOptions: $showingOptions)
                        
                        Spacer()
                            .frame(height: 150)
                                                    
//                        LayersButton()
//                        LocationButton()
                    }
                    .padding(.trailing, 10)
                    .padding(.top, 10)
                }
                
                VStack {
                    Spacer()
                    
//                    HStack {
//                        Spacer()
//        
//                        LayersButton()
//                    }
//                    .padding(.trailing, 10)
        
                    HStack {
                        Spacer()
        
                        LocationButton(moveToUserTapped: $moveToUserTapped)
                    }
                    .padding(.trailing, 10)
                    .padding(.bottom, 10)
                    
                    Spacer()
                        .frame(height: self.size.height)
                }
                .opacity(isConfirmingLocation ? 0.0 : 1.0)
            }
            .confirmationDialog("Select a color", isPresented: $showingOptions, titleVisibility: .hidden) {
                Button("Save & Exit") {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()

                    // Upload new detectors & return to properties view
                    SessionManager.shared.uploadNewDetectors()
                    dismiss()
//                    SessionManager.shared.appState = .properties
                }
                

                Button("Quit without saving", role: .destructive) {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()

//                    SessionManager.shared.appState = .properties
                    dismiss()
                }
            }
        }
    }
}

struct SensorSetupOverlayView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
//    let property: Property
        
    @Binding var size: CGSize
    @Binding var markers: [GMSMarker]
    @State var nextButtonColor: Color = Color(red: 0.18, green: 0.21, blue: 0.22)
    @State var disabledButtonColor: Color = Color(red: 0.78, green: 0.81, blue: 0.82)
    @State var nextButtonEnabled: Bool = true
//    @ObservedObject var sessionManager: SessionManager
    @StateObject var sessionManager = SessionManager.shared
    @Binding var isPresentingScanner: Bool
    @Binding var isConfirmingLocation: Bool
    @Binding var selectedSensor: Detector?
    @Binding var selectedDetector: Detector?
    @Binding var sensorTapped: Bool
    
    @Binding var annotations: [PointAnnotation]
    @Binding var pin: CLLocationCoordinate2D
    
    var body: some View {
        VStack {
            
            Spacer()
            
            ZStack {
                Rectangle()
                    .cornerRadius(15.0)
                    .ignoresSafeArea()
                    .foregroundColor(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                    .frame(maxHeight: .infinity)
                    .shadow(color: CustomColors.LightGray, radius: 2.0)
                
                VStack {
                    HStack(alignment: .center) {
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Sensor installation")
                            .font(Font.custom("Manrope-SemiBold", size: 24))
                            .foregroundColor(CustomColors.TorchGreen)
                            
                            Text("Select the sensor, then select the location and press the set button")
                              .font(Font.custom("Manrope-Medium", size: 16))
                              .foregroundColor(CustomColors.LightGray)
                              .frame(maxWidth: .infinity, alignment: .topLeading)
                              .padding(.top, 2.0)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 18.0)
                    .padding(.top, 18.0)
                    .padding(.bottom, 8.0)
                    
                    Spacer()
                        .frame(height: 15)
                    
                    // Rows of sensors
                    VStack {
                        // 1st row
                        var idx = 1
                        HStack(spacing: 15.0) {
//                            let x = // print("New detector count: \(sessionManager.newProperty!.detectors.count)")
                            ForEach(Array(sessionManager.newProperty!.detectors.enumerated()), id: \.element) { idx, detector in
                                VStack(spacing: 7.0) {
                                    ZStack {
                                        let strokeColor = detector.coordinate == nil ? Color(red: 0.78, green: 0.81, blue: 0.82) : Color.clear
                                        let bgColor = detector.coordinate == nil ? Color.clear : CustomColors.NormalSensorGray
                                        let fontColor = detector.coordinate == nil ? Color(red: 0.78, green: 0.81, blue: 0.82) : Color(red: 0.45, green: 0.53, blue: 0.55)
//                                        let x = // print("UI coordinate: \(detector)")
                                        Circle()
                                            .stroke(strokeColor, lineWidth: 1)
                                            .background(Circle().fill(bgColor))
                                            .frame(width: 60.0, height: 60.0)
                                        Text("\(idx + 1)")
                                            .font(Font.custom("Manrope-Medium", size: 18.0))
                                            .foregroundColor(fontColor)
                                        Button {
                                            // print("Clicked 1 sensor")
                                            self.selectedSensor = detector
                                            self.selectedDetector = detector
                                            self.sensorTapped = true
                                        } label: {
                                            Circle()
                                                .fill(Color.clear)
                                                .frame(width: 60.0, height: 60.0)
                                        }
                                    }
                                    
                                    Circle()
                                        .fill(self.selectedSensor!.id == detector.id ? Color.black : Color.clear)
                                        .frame(width: 5, height: 5)
                                }
                            }
                            
                            // Add sensor button
                            VStack(spacing: 7.0) {
                                ZStack {
                                    Circle()
                                        .stroke(Color(red: 0.78, green: 0.81, blue: 0.82), lineWidth: 1)
                                        .background(Circle().fill(Color.clear))
                                        .frame(width: 60.0, height: 60.0)
                                    Image(systemName: "plus")
                                        .foregroundColor(Color(red: 0.78, green: 0.81, blue: 0.82))
                                        .font(Font.system(size: 24.0))
                                    Button {
                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                        impactMed.impactOccurred()
                                        
                                        isPresentingScanner = true
                                    } label: {
                                        Circle()
                                            .fill(Color.clear)
                                            .frame(width: 60.0, height: 60.0)
                                    }
                                }

                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 5, height: 5)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 15.0)
                        
                        Spacer()
                            .frame(height: 20.0)
                        
                        HStack {
                            Spacer()
                            let idx = selectedSensor == nil ? 1 : selectedSensor!.sensorIdx!
                            let verb = selectedSensor?.coordinate == nil ? "Set" : "Change"
                            
                            Button(action: {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                var pointAnnotation = PointAnnotation(id: selectedSensor!.id, coordinate: self.pin)
                                var annotationIcon = "NewSensorIcon\(selectedSensor!.sensorIdx!)"
                                var annotationImage = UIImage(named: annotationIcon)!
                                annotationImage.scale(newWidth: 1.0)
                                pointAnnotation.image = .init(image: annotationImage, name: annotationIcon)
                    //            pointAnnotation.image?.image.scale = 4.0
                                pointAnnotation.iconAnchor = .bottom
                                pointAnnotation.iconSize = 0.25
                                pointAnnotation.iconOffset = [40, 0]
                                
                                self.annotations.append(pointAnnotation)
                                
                                self.isConfirmingLocation = true
                            }) {
                                Text("\(verb) the position for sensor \(idx)")
                                .font(.custom("Manrope-SemiBold", size: 16))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 100)
                                        .foregroundColor(selectedSensor == nil ? self.disabledButtonColor : self.nextButtonColor)
                                )
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            }
                            .disabled(selectedSensor == nil)
                            
//                            Button("\(verb) the position for sensor \(idx)") {
//                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                                impactMed.impactOccurred()
//
//                                self.isConfirmingLocation = true
//                            }
//                            .disabled(selectedSensor == nil)
//                            .font(.custom("Manrope-SemiBold", size: 16))
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 60)
//                            .foregroundColor(.white)
//                            .background(
//                                RoundedRectangle(cornerRadius: 100)
//                                    .foregroundColor(selectedSensor == nil ? self.disabledButtonColor : self.nextButtonColor)
//                            )
//                            .padding(.horizontal, 16)
//                            .padding(.bottom, 20)
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                for i in 0..<self.markers.count {
                                    if self.markers[i].userData as! String == selectedSensor!.id {
                                        // print("\(i) markers count before \(self.markers.count)")
                                        self.markers[i].map = nil
                                        self.markers.remove(at: i)
//                                        self.markers[i].userData = "remove"
                                        // print("\(i) markers count after \(self.markers.count)")
                                    }
                                    
                                    break
                                }
                                
                                sessionManager.deleteNewDetector(detector: selectedSensor!)
                            } label: {
                                Text("Delete sensor")
                                    .font(Font.custom("Manrope-SemiBold", size: 16.0))
                                    .foregroundColor(CustomColors.LightGray)
                            }
                            
                            
//                            Text("Delete sensor 1")
//                                .font(Font.custom("Manrope-SemiBold", size: 16.0))
//                                .foregroundColor(CustomColors.LightGray)
                            
                            Spacer()
                        }
                    }
                    .padding(.top, 10.0)
                    .padding(.bottom, 20.0)
                    
                    Spacer()
                }
            }
//            .frame(width: width, height: 2.2 * height / 5)
            .fixedSize(horizontal: false, vertical: true)
            .ignoresSafeArea()
            .overlay(GeometryReader { geo in
                Rectangle().fill(Color.clear).onAppear { self.size = geo.size }
            })
        }
    }
}

struct SensorConfirmLocationOverlayView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
//    let property: Property
        
    @Binding var size: CGSize
    @Binding var markers: [GMSMarker]
    @Binding var pin: CLLocationCoordinate2D
    @Binding var selectedSensor: Detector?
    @Binding var isConfirmingLocation: Bool
    @State var nextButtonColor: Color = Color(red: 0.18, green: 0.21, blue: 0.22)
    @State var nextButtonEnabled: Bool = true
//    @ObservedObject var sessionManager: SessionManager
    @StateObject var sessionManager = SessionManager.shared
    
    var body: some View {
        VStack {
            Spacer()
            
            ZStack {
                Rectangle()
                    .cornerRadius(15.0)
                    .ignoresSafeArea()
                    .foregroundColor(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                    .frame(maxHeight: .infinity)
                    .shadow(color: CustomColors.LightGray, radius: 2.0)
                
                VStack {
                    
                    Spacer()
                        .frame(height: 15)
                    
                    // Rows of sensors
                    VStack {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                sessionManager.setDetectorCoordinate(detector: selectedSensor!, coordinate: self.pin)
                                selectedSensor?.coordinate = self.pin
                                // print("Pin position: \(self.pin)")
                                // print("Set coordinate: \(selectedSensor?.coordinate)")
                                
                                let sensorMarker = GMSMarker(position: self.pin)
                                sensorMarker.userData = selectedSensor!.id
                                let assetName = "NewSensorIcon\(selectedSensor!.sensorIdx!)"
                                // print("Got asset name: \(assetName)")
                                var markerImage = UIImage(named: assetName)
                                markerImage = UIImage(cgImage: (markerImage?.cgImage)!, scale: 4.0, orientation: (markerImage?.imageOrientation)!)
                                sensorMarker.icon = markerImage
                                
//                                let sensorView = SensorIconView(sensorName: "1")
////                                sensorView.sensorName = "1"
//                                let sensorMarker = GMSMarker(position: self.pin!.position)
//                                sensorMarker.iconView = sensorView!
//
//                                // print(sensorView.bounds)
                                
                                for i in 0..<self.markers.count {
                                    if self.markers[i].userData as! String == selectedSensor!.id {
                                        // print("\(i) markers count before \(self.markers.count)")
                                        self.markers[i].map = nil
                                        self.markers.remove(at: i)
//                                        self.markers[i].userData = "remove"
                                        // print("\(i) markers count after \(self.markers.count)")
                                        
                                        break
                                    }
                                }
                                
                                self.markers.append(sensorMarker)
                                
                                // print("markers: \(self.markers)")
////                                // print(sensorView.propertyImageView.image)
                                
                                self.isConfirmingLocation = false
                            }) {
                                Text("Confirm position")
                                .font(.custom("Manrope-SemiBold", size: 16))
                                .frame(maxWidth: .infinity)
                                .frame(height: 60)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 100)
                                        .foregroundColor(self.nextButtonColor)
                                )
                                .padding(.horizontal, 16)
                                .padding(.bottom, 20)
                            }
                            .disabled(!nextButtonEnabled)
                            
//                            Button("Confirm position") {
//                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                                impactMed.impactOccurred()
//
//                                sessionManager.setDetectorCoordinate(detector: selectedSensor!, coordinate: self.pin)
//                                selectedSensor?.coordinate = self.pin
//                                // print("Pin position: \(self.pin)")
//                                // print("Set coordinate: \(selectedSensor?.coordinate)")
//
//                                let sensorMarker = GMSMarker(position: self.pin)
//                                sensorMarker.userData = selectedSensor!.id
//                                let assetName = "NewSensorIcon\(selectedSensor!.sensorIdx!)"
//                                // print("Got asset name: \(assetName)")
//                                var markerImage = UIImage(named: assetName)
//                                markerImage = UIImage(cgImage: (markerImage?.cgImage)!, scale: 4.0, orientation: (markerImage?.imageOrientation)!)
//                                sensorMarker.icon = markerImage
//
////                                let sensorView = SensorIconView(sensorName: "1")
//////                                sensorView.sensorName = "1"
////                                let sensorMarker = GMSMarker(position: self.pin!.position)
////                                sensorMarker.iconView = sensorView!
////
////                                // print(sensorView.bounds)
//
//                                for i in 0..<self.markers.count {
//                                    if self.markers[i].userData as! String == selectedSensor!.id {
//                                        // print("\(i) markers count before \(self.markers.count)")
//                                        self.markers[i].map = nil
//                                        self.markers.remove(at: i)
////                                        self.markers[i].userData = "remove"
//                                        // print("\(i) markers count after \(self.markers.count)")
//
//                                        break
//                                    }
//                                }
//
//                                self.markers.append(sensorMarker)
//
//                                // print("markers: \(self.markers)")
//////                                // print(sensorView.propertyImageView.image)
//
//                                self.isConfirmingLocation = false
//                            }
//                            .disabled(!nextButtonEnabled)
//                            .font(.custom("Manrope-SemiBold", size: 16))
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 60)
//                            .foregroundColor(.white)
//                            .background(
//                                RoundedRectangle(cornerRadius: 100)
//                                    .foregroundColor(self.nextButtonColor)
//                            )
//                            .padding(.horizontal, 16)
//                            .padding(.bottom, 20)
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                for i in 0..<self.markers.count {
                                    if self.markers[i].userData as! String == selectedSensor!.id {
                                        // print("\(i) markers count before \(self.markers.count)")
                                        self.markers[i].map = nil
                                        self.markers.remove(at: i)
//                                        self.markers[i].userData = "remove"
                                        // print("\(i) markers count after \(self.markers.count)")
                                        
                                        break
                                    }
                                }
                                
                                sessionManager.deleteNewDetector(detector: selectedSensor!)
                                
                                self.isConfirmingLocation = false
                            } label: {
                                Text("Delete sensor")
                                    .font(Font.custom("Manrope-SemiBold", size: 16.0))
                                    .foregroundColor(CustomColors.LightGray)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.top, 10.0)
                    .padding(.bottom, 20.0)
                    
                    Spacer()
                }
            }
//            .frame(width: width, height: 2.2 * height / 5)
            .fixedSize(horizontal: false, vertical: true)
            .ignoresSafeArea()
            .overlay(GeometryReader { geo in
                Rectangle().fill(Color.clear).onAppear {
//                    self.size = geo.size
                }
            })
        }
    }
}

//struct DeviceScanerView: View {
//    @State var isPresentingScanner: Bool
//
//
//    var body: some View {
//        CodeScannerView(codeTypes: [.qr]) { response in
//            if case let .success(result) = response {
//                // print(result.string)
//                isPresentingScanner = false
//            }
//        }
//    }
//}

struct ExitButton: View {
    @Binding var showingOptions: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 48.0, height: 48.0)
            Image(systemName: "multiply")
                .frame(width: 48.0, height: 48.0)
                .foregroundColor(CustomColors.TorchGreen)
            Button {
                withAnimation {
                    showingOptions = true
                }
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray.opacity(0.5), radius: 15.0)
    }
}

struct SensorIconView: View {
    var sensorName: String

    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.red)
                .frame(width: 100, height: 100)
                .fixedSize(horizontal: true, vertical: false)
                .shadow(color: Color.gray,radius: 5.0)

            HStack {
                Image("SensorIcon")
                    .resizable()
                    .frame(width: 20, height: 20)

                Text(sensorName)
            }
        }
    }
}

//struct PlaceSensorView_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaceSensorView()
//    }
//}
