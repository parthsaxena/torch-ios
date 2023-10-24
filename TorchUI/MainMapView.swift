//
//  MapView.swift
//  TorchUI
//
//  Created by Parth Saxena on 6/28/23.
//

import SwiftUI
import CoreLocation
import GoogleMaps
import CodeScanner
import MapboxMaps

struct MainMapView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    
    @ObservedObject var sessionManager = SessionManager.shared    
    
    // Google maps tutorial START
    static var detectors: [Detector] = []
    @State var annotations: [PointAnnotation] = [PointAnnotation]()
    
    @State var hideOverlay: Bool = false
    @State var showDetectorDetails: Bool = false
    @State var zoomInCenter: Bool = false
    @State var selectedDetector: Detector?
    @State var selectedDetectorIndex: Int = -1
    @State var newDetector: Detector?
    @State var newDetectorIndex: Int = 0
//    @State var selectedDetector: Detector? = SessionManager.shared.properties[0].detectors[0]
    @State var selectedMarker: GMSMarker?
    
    @State var mapOffset: CGSize = CGSize()
    @State var size: CGSize = CGSize()
    
    @State private var dragOffset = CGSize.zero
    
    @State var zoomLevel: CGFloat = 12
    
    @State var isAddingSensor: Bool = false
    @State var isPresentingScanner: Bool = false
        
    @State var isConfirmingLocation: Bool = false
        
    @State var pin: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    @State var needsLocationPin: Bool = false
    
    @State var sensorTapped: Bool = false
    
    @State var zoomChanged: Bool = false
    
    @State var moveToUserTapped: Bool = false
    
    @State var showingDeletePropertyOptions: Bool = false
    @State var showingDeleteDetectorOptions: Bool = false
    var combinedBinding: Binding<Bool> {
            Binding(
                get: { let x = print("BIND:\(self.showingDeletePropertyOptions || self.showingDeleteDetectorOptions)");
                    return self.showingDeletePropertyOptions || self.showingDeleteDetectorOptions },
                set: { newValue in
                    // Decide how you want to handle the set. For this example, I'll set both states.
                    self.showingDeletePropertyOptions = newValue
                    self.showingDeleteDetectorOptions = newValue
                }
            )
        }
    
    // Google maps tutorial END
    
    init() {
//        print("MARKERS: \(markers)")
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Maps
//                let diameter = zoomInCenter ? geometry.size.width : (geometry.size.height * 2)
//                MapViewControllerBridge(markers: markers, zoomLevel: $zoomLevel, isConfirmingLocation: $isConfirmingLocation, mapBottomOffset: $mapOffset.height, selectedMarker: $selectedMarker, selectedDetector: $selectedDetector, showDetectorDetails: $showDetectorDetails, detectors: sessionManager.selectedProperty!.detectors, property: sessionManager.selectedProperty!, onAnimationEnded: {
//                    self.zoomInCenter = true
//                }, mapViewWillMove: { (isGesture) in
//                    guard isGesture else { return }
//                    self.zoomInCenter = false
//                }, mapViewDidChange: { (position) in
//                    if !isConfirmingLocation {
//                        self.pin = position.target
//                        print("Map did change: \(position.target)")
//                        print("Map did change, pin: \(self.pin)")
//                    }
//                })
//                MapboxMap(zoomLevel: $zoomLevel)
                MapboxMapViewWrapper(showDetectorDetails: $showDetectorDetails, zoomLevel: $zoomLevel, selectedDetectorIndex: $selectedDetectorIndex, annotations: $annotations, pin: self.$pin, needsLocationPin: $needsLocationPin, sensorTapped: $sensorTapped, moveToUserTapped: $moveToUserTapped, zoomChanged: $zoomChanged)
                .ignoresSafeArea()
                .animation(.easeIn)
//                .background(Color(red: 254.0/255.0, green: 1, blue: 220.0/255.0))
                
                if (self.newDetector != nil) {
                    ZStack {
                        VStack {
                            Spacer()
                            
//                            Image("Pin")
//                                .resizable()
//                                .frame(width: 60, height: 69)
//                                .padding(.bottom, 69 + 20)
                            
                            Spacer()
                        }
                        .padding(.bottom, self.size.height)
                    }
                }
                    
                let DETECTOR_MIN_OFFSET = 50.0
                let PROPERTY_MIN_OFFSET = 75.0
                let THRESHOLD = 150.0
                let ANIMATION_DURATION = 0.1
                
                // Overlay
                if showDetectorDetails && !hideOverlay {
//                    VStack {
                    let x = print("chhh", SessionManager.shared.properties, "ooo", SessionManager.shared.selectedPropertyIndex)
                    DetectorDetailOverlayView(size: $size, mapOffset: $mapOffset, detector: SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[SessionManager.shared.selectedDetectorIndex], sessionManager: sessionManager, showingDeleteDetectorOptions: $showingDeleteDetectorOptions)
                        .offset(x: 0, y: self.dragOffset.height)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    print("Gesture: \(gesture.translation), size: \(self.size)")
//                                    if gesture.translation.height <= self.size.height && gesture.translation.height > 0 {
//                                        self.dragOffset = gesture.translation
//                                        self.mapOffset.height = self.size.height gesture.translation.height
//                                    }
                                    if gesture.translation.height < 0 && self.dragOffset.height > 0 {
                                        print("Dragging up")
                                        self.dragOffset.height = (self.size.height - DETECTOR_MIN_OFFSET) - fabs(gesture.translation.height)
                                        self.mapOffset.height = DETECTOR_MIN_OFFSET + fabs(gesture.translation.height)
                                    } else if gesture.translation.height > 0 && gesture.translation.height <= self.size.height {
                                        print("Dragging down")
                                        self.dragOffset = gesture.translation
                                        self.mapOffset.height = (self.size.height - gesture.translation.height)
                                    }
                                }
                                .onEnded { _ in
                                    if self.dragOffset.height + THRESHOLD > self.size.height {
                                        print("Threshold")//
                                        withAnimation(.easeIn(duration: ANIMATION_DURATION)) {
                                            self.dragOffset.height = self.size.height - DETECTOR_MIN_OFFSET
                                            self.mapOffset.height = DETECTOR_MIN_OFFSET
                                        }
                                        
                                    } else {
                                        withAnimation(.easeIn(duration: ANIMATION_DURATION)) {
                                            self.dragOffset = .zero
                                            self.mapOffset.height = (self.size.height)
                                        }
                                    }
                                }
                        )
                        .confirmationDialog("Select a color", isPresented: combinedBinding, titleVisibility: .hidden) {
                            Button(showingDeletePropertyOptions ? "Delete property" : "Delete detector", role: .destructive) {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()

                                // Upload new detectors & return to properties view
//                                SessionManager.shared.uploadNewDetectors()
//                                print("Deleting properties")
                                if (showingDeletePropertyOptions) {
                                    SessionManager.shared.deleteProperty()
                                    withAnimation {
                                        SessionManager.shared.appState = .properties
                                    }
                                } else if (showingDeleteDetectorOptions) {
//                                    withAnimation {
//                                        SessionManager.shared.appState = .properties
//                                    }
                                    withAnimation(.easeIn(duration: 0.1)) {
                                        self.dragOffset = .zero
                                    }
                                    showDetectorDetails = false
                                    selectedDetector = nil
                                    SessionManager.shared.deleteDetector()
                                }
                                combinedBinding.wrappedValue = false
                                dismiss()
                            }
                        }
//                            .transition(AnyTransition.move(edge: .top))
//                        //                        .shadow(color: CustomColors.LightGray, radius: 5.0)
//                    }
//                    .animation(.easeInOut)
                    
                    HStack {
                        BackButton(selectedDetector: $selectedDetector, showDetectorDetails: $showDetectorDetails, dragOffset: $dragOffset)
                            .padding(.leading, 10)
                            .padding(.top, 10)
                        
                        Spacer()
                    }
                    
//                    HStack {
//                        Spacer()
//                        
//                        Text(selectedDetector!.deviceName)
//                            .font(Font.custom("Manrope-SemiBold", fixedSize: 20))
//                            .kerning(-1)
//                            .foregroundColor(CustomColors.TorchGreen)
//                            .padding(.top, 25)
////                            .shadow(color: CustomColors.LightGray, radius: 5)
//                        
//                        Spacer()
//                    }
                    
                    // Right side buttons: Hamburger, ZoomIn, ZoomOut, Layers, CurrentLocation
                    HStack {
                        Spacer()
                        VStack(spacing: 1) {
                            HamburgerButton(hideOverlay: $hideOverlay)
                            
                            Spacer()
                                .frame(height: 150)                                                        
                        }
                        .padding(.trailing, 10)
                        .padding(.top, 10)
                    }
                    
                    VStack {
                        Spacer()
                        
//                        HStack {
//                            Spacer()
//            
//                            LayersButton()
//                        }
//                        .padding(.trailing, 10)
            
                        HStack {
                            Spacer()
            
                            LocationButton(moveToUserTapped: $moveToUserTapped)
                        }
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                        
                        Spacer()
                            .frame(height: self.mapOffset.height)
                    }
                    
                }  else if isConfirmingLocation {
                    AddDetectorConfirmLocationOverlayView(size: $size, annotations: $annotations, pin: $pin, newDetector: $newDetector, isConfirmingLocation: $isConfirmingLocation, needsLocationPin: $needsLocationPin, newDetectorIndex: self.$newDetectorIndex)
                } else if !hideOverlay {
                    
                    PropertyDetailOverlayView(isPresentingScanner: $isPresentingScanner, zoomLevel: $zoomLevel, property: sessionManager.selectedProperty!, mapOffset: $mapOffset, size: $size, sessionManager: sessionManager, selectedDetectorIndex: $selectedDetectorIndex, showDetectorDetails: $showDetectorDetails,selectedDetector: $selectedDetector, selectedMarker: $selectedMarker, detectors: MainMapView.detectors, annotations: $annotations, newDetector: $newDetector, isConfirmingLocation: $isConfirmingLocation, pin: self.$pin, sensorTapped: $sensorTapped, showingOptions: $showingDeletePropertyOptions)
                        .offset(x: 0, y: self.dragOffset.height)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    print("Gesture: \(gesture.translation), size: \(self.size)")
//                                    if gesture.translation.height <= self.size.height && gesture.translation.height > 0 {
//                                        self.dragOffset = gesture.translation
//                                        self.mapOffset.height = self.size.height gesture.translation.height
//                                    }
                                    if gesture.translation.height < 0 && self.dragOffset.height > 0 {
                                        print("Dragging up")
                                        self.dragOffset.height = (self.size.height - PROPERTY_MIN_OFFSET) - fabs(gesture.translation.height)
                                        self.mapOffset.height = PROPERTY_MIN_OFFSET + fabs(gesture.translation.height)
                                    } else if gesture.translation.height > 0 && gesture.translation.height <= self.size.height {
                                        print("Dragging down")
                                        self.dragOffset = gesture.translation
                                        self.mapOffset.height = (self.size.height - gesture.translation.height)
                                    }
                                }
                                .onEnded { _ in
                                    if self.dragOffset.height + THRESHOLD > self.size.height {
                                        print("Threshold")//
                                        withAnimation(.easeIn(duration: ANIMATION_DURATION)) {
                                            self.dragOffset.height = self.size.height - PROPERTY_MIN_OFFSET
                                            self.mapOffset.height = PROPERTY_MIN_OFFSET
                                        }
                                        
                                    } else {
                                        withAnimation(.easeIn(duration: ANIMATION_DURATION)) {
                                            self.dragOffset = .zero
                                            self.mapOffset.height = (self.size.height)
                                        }
                                    }
                                }
                        )
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
                                        
                                        print("Got device EUI: \(result.string)")
                                        isPresentingScanner = false
                                        
                                        // create detector model
                                        var detector = Detector(id: result.string, deviceName: String(sessionManager.selectedProperty!.detectors.count + 1), deviceBattery: 0.0, coordinate: nil, selected: true, sensorIdx: sessionManager.selectedProperty!.detectors.count + 1)
                                        self.newDetector = detector
                                        self.newDetectorIndex = sessionManager.selectedProperty!.detectors.count
                                        needsLocationPin = true
                                        
                                        // manually appending since selected==False already for all other detectors
                                        SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.append(detector)
                                         sessionManager.selectedProperty!.detectors.append(detector)
                                        
                                        let x = print("Added, new detector count: \(sessionManager.selectedProperty!.detectors.count)")
                                    }
                                }
                                .ignoresSafeArea(.container)
                            }
                        }
                        .confirmationDialog("Select a color", isPresented: combinedBinding, titleVisibility: .hidden) {
                            Button(showingDeletePropertyOptions ? "Delete property" : "Delete sensor", role: .destructive) {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()

                                // Upload new detectors & return to properties view
//                                SessionManager.shared.uploadNewDetectors()
//                                print("Deleting properties")
                                if (showingDeletePropertyOptions) {
                                    SessionManager.shared.deleteProperty()
                                    withAnimation {
                                        SessionManager.shared.appState = .properties
                                    }
                                } else if (showingDeleteDetectorOptions) {
                                    SessionManager.shared.deleteDetector()
                                                    
                                    withAnimation(.easeIn(duration: 0.1)) {
                                        self.dragOffset = .zero
                                    }
                                    showDetectorDetails = false
                                    selectedDetector = nil
                                }
                                combinedBinding.wrappedValue = false
                                dismiss()
                            }
                        }
                    
                    //
                    HStack {
                        PropertiesBackButton(showDetectorDetails: $showDetectorDetails)
                            .padding(.leading, 10)
                            .padding(.top, 10)
                        
                        Spacer()
                    }

                    // Right side buttons: Hamburger, ZoomIn, ZoomOut, Layers, CurrentLocation
                    HStack {
                        Spacer()
                        VStack(spacing: 1) {
                            HamburgerButton(hideOverlay: $hideOverlay)
                            
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
                                                
                        HStack {
                            Spacer()
            
                            ZoomInButton(zoomLevel: $zoomLevel, zoomChanged: $zoomChanged)
                        }
                        .padding(.trailing, 10)
                        
                        HStack {
                            Spacer()
            
                            ZoomOutButton(zoomLevel: $zoomLevel, zoomChanged: $zoomChanged)
                        }
                        .padding(.trailing, 10)
                        
                        Spacer()
                            .frame(height: 50)
                        
//                        HStack {
//                            Spacer()
//            
//                            LayersButton()
//                        }
//                        .padding(.trailing, 10)
            
                        HStack {
                            Spacer()
            
                            LocationButton(moveToUserTapped: $moveToUserTapped)
                        }
                        .padding(.trailing, 10)
                        .padding(.bottom, 10)
                        
                        Spacer()
                            .frame(height: self.mapOffset.height)
                    }
                }
                //            DetectorDetailOverlayView(detector: customDetector)
            }
//            .animation(.easeInOut)
        }
    }
}

struct DetectorDetailOverlayView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    @Binding var size: CGSize
    @Binding var mapOffset: CGSize
    
    let detector: Detector
    
    @ObservedObject var sessionManager: SessionManager
    
    @Binding var showingDeleteDetectorOptions: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 5.0)
                        .frame(width: 30, height: 4)
                        .foregroundColor(AuthenticationManager.shared.authState.rawValue >= AuthState.accountName.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                    
                    Spacer()
                }
                
                ZStack {
                    Rectangle()
                        .cornerRadius(15.0)
                        .ignoresSafeArea()
                        .foregroundColor(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                        .frame(maxHeight: .infinity)
                        .shadow(color: CustomColors.LightGray.opacity(0.5), radius: 2.0)
                    
                    VStack {
                        HStack(spacing: 1) {
                            
                            let x = sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].sensorIdx as! Int
                            
                            
                            Text("Sensor \(x)")
                                .font(Font.custom("Manrope-SemiBold", size: 24.0))
                                .kerning(-1)
                                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                                .padding(.leading, 15)
                                .padding(.top, 20)
                                                    
                            Spacer()
                            
                            Text("\(Int(sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].deviceBattery as! Double))%")
                                .font(Font.custom("Manrope-SemiBold", size: 13.0))
                                .foregroundColor(CustomColors.LightGray)
                                .padding(.top, 20)
    //                            .padding(.leading, 20)
                            
                            
                            let deviceBattery = sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].deviceBattery as! Double
                            BatteryView(batteryLevel: deviceBattery)
                                .frame(width: 25, height: 10)
                                .padding(.top, 20)
                                .padding(.trailing, 15)
                                .padding(.leading, 5)
                            
                            Image(systemName: "ellipsis")
                                .foregroundColor(CustomColors.LightGray)
                                .padding(.trailing, 23.0)
                                .padding(.top, 20)
                                .onTapGesture {
                                    print("Dots tapped")
                                    showingDeleteDetectorOptions.toggle()
                                }
                        }
                        
                        HStack {
                            Text("Fire Probability")
                                .font(Font.custom("Manrope-Medium", size: 18.0))
                                .kerning(-1)
                                .foregroundColor(Color(red: 115.0/255.0, green: 136.0/255.0, blue: 140.0/255.0))
    //                        115, 136, 140
                                .padding(.top, 1)
                                                    
                            Spacer()
                        }
                        .padding(.leading, 15)
                        
                        HStack {
                            
                            let fireRating = Int(sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].measurements["fire_rating"] ?? "80")
                            let highRisk = (sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].threat == Threat.Red)
                            let mediumRisk = !highRisk && (sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].threat == Threat.Yellow)
                            let riskText = highRisk ? "High Risk" : (mediumRisk ? "Medium Risk" : "Low Risk")
                            let riskColor = highRisk ? CustomColors.TorchRed : (mediumRisk ? CustomColors.WarningYellow : CustomColors.GoodGreen)
                            
                            VStack {
                                Text("\(sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].measurements["fire_rating"] ?? "80")%")
                                    .font(Font.custom("Manrope-SemiBold", size: 36.0))
                                    .kerning(-1)
                                    .foregroundColor(.white)
                                
                                Text(riskText)
                                    .font(Font.custom("Manrope-Bold", size: 14))
                                    .kerning(-0.5)
                                    .foregroundColor(.white)
                            }
                            .frame(width: 0.8 * width / 3)
    //                            .frame(width: width / 3)
                            .frame(height: width / 3 * 0.7)
                            .background(riskColor)
                            .cornerRadius(12.0)
                            .shadow(color: CustomColors.DetectorDetailsShadow, radius: 12.0, x: 0.0, y: 4.0)
                            .padding(.leading, 15)
                                                    
                            
                            Spacer()
                                .frame(width: 10)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack(spacing: 5) {
                                        Text("Temperature")
                                            .font(Font.custom("Manrope-SemiBold", size: 13.0))
                                            .kerning(-0.5)
                                            .foregroundColor(CustomColors.LightGray)
    //                                        .padding(.leading, 5)
                                        Image("Thermometer")
                                            .resizable()
                                            .frame(width: 20.0, height: 20.0)
                                    }
                                    
                                    HStack(spacing: 5) {
                                        Text("Humidity")
                                            .font(Font.custom("Manrope-SemiBold", size: 13.0))
                                            .kerning(-0.5)
                                            .foregroundColor(CustomColors.LightGray)
    //                                        .padding(.leading, 5)
                                        Image("Humidity")
                                            .resizable()
                                            .frame(width: 20.0, height: 20.0)
                                    }
                                }
                                .padding(.trailing, 12)
                                
    //                            Spacer()
                                
                                VStack {
                                    Text("\(sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].measurements["temperature"] ?? "28")°C")
                                        .font(Font.custom("Manrope-Bold", size: 14.0))
                                        .foregroundColor(CustomColors.TorchRed)
                                    
                                    Spacer()
                                        .frame(height: 12)
                                    
                                    Text("\(sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].measurements["humidity"] ?? "85")%")
                                        .font(Font.custom("Manrope-Bold", size: 14.0))
                                        .foregroundColor(CustomColors.GoodGreen)
                                }
                                
                                VStack(alignment: .trailing) {
                                    HStack(spacing: 1) {
                                        Image(systemName: "arrow.up")
                                            .foregroundColor(CustomColors.LightGray)
                                            .font(.system(size: 13.0))
    //                                        .padding(.leading, 10)
                                        
                                        Text("2°C")
                                            .font(Font.custom("Manrope-Bold", size: 14.0))
                                            .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
    //                                        .padding(.trailing, 10)
                                    }
                                    
                                    Spacer()
                                        .frame(height: 12)
                                    
                                    HStack(spacing: 1) {
                                        Image(systemName: "arrow.up")
                                            .foregroundColor(CustomColors.LightGray)
                                            .font(.system(size: 13.0))
    //                                        .font(.system(Font.TextStyle.body))

                                        Text("5%")
                                            .font(Font.custom("Manrope-Bold", size: 14.0))
                                            .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
    //                                        .padding(.trailing, 10)
                                    }
                                }
                                .padding(.leading, 7)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: width / 3 * 0.7)
                            .background(colorScheme == .dark ? Color(red: 0.24, green: 0.26, blue: 0.27) : Color.white)
                            .cornerRadius(12.0)
                            .shadow(color: CustomColors.DetectorDetailsShadow, radius: 12.0, x: 0.0, y: 4.0)
                            .padding(.trailing, 15)
                        }
                        
                        // Bottom 3 menus
                        HStack {
                            // Thermal camera
                            VStack {
                                ZStack {
                                    HStack {
                                        Text("Thermal \ncamera")
                                            .font(Font.custom("Manrope-SemiBold", size: 14.0))
                                            .kerning(-0.5)
                                            .foregroundColor(CustomColors.LightGray)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 15)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Image(systemName: "info.circle")
                                            .foregroundColor(CustomColors.LightGray)
                                    }
                                    .padding(.trailing, 15)
                                    .padding(.bottom, 15)
                                }
                                
                                Spacer()
                                    .frame(height: 10)
                                
//                                HStack {
//                                    Text("95%")
//                                        .font(Font.custom("Manrope-SemiBold", size: 30.0))
//                                        .kerning(-1)
//                                        .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
//                                    
//                                    Spacer()
//                                }
//                                .padding(.leading, 15)
                                
                                ZStack {
                                    HStack {
//                                        let img = Image("Fire65")
                                        
//                                        var fireImage = UIImage(named: "FireYellow")
//                                        let uiImggg = UIImage(cgImage: (fireImage?.cgImage)!, scale: 5.0, orientation: (fireImage?.imageOrientation)!)
//                                        let imgggg = Image.init(uiImage: uiImggg)
                                        
                                        let highRisk = (sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].thermalStatus == Threat.Red)
                                        let mediumRisk = !highRisk && (sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].thermalStatus == Threat.Yellow)
                                        let riskText = highRisk ? "Red alert" : (mediumRisk ? "Warning" : "Normal")
                                        let riskImage = highRisk ? "FireRed" : (mediumRisk ? "FireYellow" : "Checkmark")
                                        let riskColor = highRisk ? CustomColors.TorchRed : (mediumRisk ? CustomColors.WarningYellow : CustomColors.GoodGreen)

                                        Text("\(riskText)  \(Image.init(uiImage: UIImage(cgImage: UIImage(named: riskImage)!.cgImage!, scale: 5.0, orientation: UIImage(named: riskImage)!.imageOrientation)))")
    //                                        .frame(width: 60)
                                            .font(Font.custom("Manrope-Bold", size: 14))
                                            .kerning(-0.5)
                                            .foregroundColor(riskColor)
                                        
                                        Spacer()
                                    }
                                }
    //                            .frame(width: .infinity, height: 1)
                                .padding(.horizontal, 15)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: (width - 60) / 3 * 0.8)
                            .background(colorScheme == .dark ? Color(red: 0.24, green: 0.26, blue: 0.27) : Color(red: 1.0, green: 1.0, blue: 1.0))
                            .cornerRadius(12.0)
                            .shadow(color: CustomColors.DetectorDetailsShadow, radius: 12.0, x: 0.0, y: 4.0)
                            .padding(.leading, 15)
                            
                            Spacer()
                                .frame(width: 10)
                            
                            // Spectral Analysis
                            VStack {
                                ZStack {
                                    HStack {
                                        Text("Spectral \nanalysis")
                                            .font(Font.custom("Manrope-SemiBold", size: 14.0))
                                            .kerning(-0.5)
                                            .foregroundColor(CustomColors.LightGray)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 15)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Image(systemName: "info.circle")
                                            .foregroundColor(CustomColors.LightGray)
                                    }
                                    .padding(.trailing, 15)
                                    .padding(.bottom, 15)
                                }
                                
                                Spacer()
                                    .frame(height: 10)
                                
//                                HStack {
//                                    Text("82%")
//                                        .font(Font.custom("Manrope-SemiBold", size: 30.0))
//                                        .kerning(-1)
//                                        .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
//                                    
//                                    Spacer()
//                                }
//                                .padding(.leading, 15)
                                
                                HStack {
//                                    var fireImage = UIImage(named: "FireRed")
//                                    let uiImg = UIImage(cgImage: (fireImage?.cgImage)!, scale: 5.0, orientation: (fireImage?.imageOrientation)!)
//                                    let img1 = Image(uiImage: uiImg)
//
                                    
//                                    Text("Red alert  \(img1)")
                                    
                                    let highRisk = (sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].spectralStatus == Threat.Red)
                                    let mediumRisk = !highRisk && (sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].spectralStatus == Threat.Yellow)
                                    let riskText = highRisk ? "Red alert" : (mediumRisk ? "Warning" : "Normal")
                                    let riskImage = highRisk ? "FireRed" : (mediumRisk ? "FireYellow" : "Checkmark")
                                    let riskColor = highRisk ? CustomColors.TorchRed : (mediumRisk ? CustomColors.WarningYellow : CustomColors.GoodGreen)

                                    Text("\(riskText)  \(Image.init(uiImage: UIImage(cgImage: UIImage(named: riskImage)!.cgImage!, scale: 5.0, orientation: UIImage(named: riskImage)!.imageOrientation)))")
//                                        .frame(width: 60)
                                        .font(Font.custom("Manrope-Bold", size: 14))
                                        .kerning(-0.5)
                                        .foregroundColor(riskColor)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 15)
                            }
                            .frame(width: (width - 45) / 3)
                            .frame(height: (width - 60) / 3 * 0.8)
                            .background(colorScheme == .dark ? Color(red: 0.24, green: 0.26, blue: 0.27) : Color.white)
                            .cornerRadius(12.0)
                            .shadow(color: CustomColors.DetectorDetailsShadow, radius: 12.0, x: 0.0, y: 4.0)
                            
                            Spacer()
                                .frame(width: 10)
                            
                            
                            // Smoke
                            VStack {
                                ZStack {
                                    HStack {
                                        Text("Smoke\n")
                                            .font(Font.custom("Manrope-SemiBold", size: 14.0))
                                            .kerning(-0.5)
                                            .foregroundColor(CustomColors.LightGray)
                                        
                                        Spacer()
                                    }
                                    .padding(.leading, 15)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Image(systemName: "info.circle")
                                            .foregroundColor(CustomColors.LightGray)
                                    }
                                    .padding(.trailing, 15)
                                    .padding(.bottom, 15)
                                }
                                
                                Spacer()
                                    .frame(height: 10)
                                
//                                HStack {
//                                    Text("25%")
//                                        .font(Font.custom("Manrope-SemiBold", size: 30.0))
//                                        .kerning(-1)
//                                        .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
//                                    
//                                    Spacer()
//                                }
//                                .padding(.leading, 15)
                                
                                HStack {
//                                    let smokeStatus =
                                    let highRisk = (sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].smokeStatus == Threat.Red)
                                    let mediumRisk = !highRisk && (sessionManager.properties[sessionManager.selectedPropertyIndex].detectors[sessionManager.selectedDetectorIndex].smokeStatus == Threat.Yellow)
                                    let riskText = highRisk ? "Red alert" : (mediumRisk ? "Warning" : "Normal")
                                    let riskImage = highRisk ? "FireRed" : (mediumRisk ? "FireYellow" : "Checkmark")
                                    let riskColor = highRisk ? CustomColors.TorchRed : (mediumRisk ? CustomColors.WarningYellow : CustomColors.GoodGreen)

                                    Text("\(riskText)  \(Image.init(uiImage: UIImage(cgImage: UIImage(named: riskImage)!.cgImage!, scale: 5.0, orientation: UIImage(named: riskImage)!.imageOrientation)))")
//                                        .frame(width: 60)
                                        .font(Font.custom("Manrope-Bold", size: 14))
                                        .kerning(-0.5)
                                        .foregroundColor(riskColor)
                                    
                                    Spacer()
                                }
                                .padding(.leading, 15)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: (width - 60) / 3 * 0.8)
                            .background(colorScheme == .dark ? Color(red: 0.24, green: 0.26, blue: 0.27) : Color.white)
                            .cornerRadius(12.0)
                            .shadow(color: CustomColors.DetectorDetailsShadow, radius: 12.0, x: 0.0, y: 4.0)
                            .padding(.trailing, 15)
                        }
                        .padding(.bottom, 20)
                    }
                }
    //            .frame(width: width, height: 2.2 * height / 5)
            }
            .fixedSize(horizontal: false, vertical: true)
            .overlay(GeometryReader { geo in
                Rectangle().fill(Color.clear).onAppear {
                    self.size = geo.size
                    self.mapOffset = geo.size
                }.onChange(of: geo.size) { updatedSize in
                    self.size = updatedSize
                    self.mapOffset = geo.size
                }
            })
        }
    }
}

struct PropertyDetailOverlayView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var isPresentingScanner: Bool
    
    @Binding var zoomLevel: CGFloat
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    let property: Property
    
    @Binding var mapOffset: CGSize
    @Binding var size: CGSize
    @ObservedObject var sessionManager: SessionManager
    @Binding var selectedDetectorIndex: Int
    @Binding var showDetectorDetails: Bool
    @Binding var selectedDetector: Detector?
    @Binding var selectedMarker: GMSMarker?
    var detectors: [Detector]
    @Binding var annotations: [PointAnnotation]
    
    @Binding var newDetector: Detector?
    @Binding var isConfirmingLocation: Bool
    @State var nextButtonColor: Color = Color(red: 0.18, green: 0.21, blue: 0.22)
    
    @Binding var pin: CLLocationCoordinate2D
    
    @Binding var sensorTapped: Bool
    
    @Binding var showingOptions: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack {
                HStack {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 5.0)
                        .frame(width: 30, height: 4)
                        .foregroundColor(AuthenticationManager.shared.authState.rawValue >= AuthState.accountName.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                    
                    Spacer()
                }
                
                ZStack {
                    Rectangle()
                        .cornerRadius(15.0)
                        .ignoresSafeArea()
                        .foregroundColor(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                        .frame(maxHeight: .infinity)
                        .shadow(color: CustomColors.LightGray.opacity(0.5), radius: 2.0)
                    
                    VStack {
                        // Property heading
                        HStack(alignment: .center) {
                            Rectangle()
                                .foregroundColor(.clear)
                                .frame(width: 60, height: 60)
                                .background(
                                    AsyncImage(url: URL(string: property.propertyImage)) { image in
                                        image.resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 60, height: 60)
                                            .clipped()
                                    } placeholder: {
                                        ProgressView()
                                    }
                                )
                                .cornerRadius(12)
                            
                            Spacer()
                                .frame(width: 15)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(property.propertyName)
                                .font(Font.custom("Manrope-SemiBold", size: 16))
                                .kerning(-1)
                                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                                
                                Text("\(property.detectors.count) Detectors")
                                  .font(Font.custom("Manrope-Medium", size: 14))
                                  .kerning(-0.5)
                                  .foregroundColor(CustomColors.LightGray)
                                  .frame(maxWidth: .infinity, minHeight: 20, maxHeight: 20, alignment: .topLeading)
                            }
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            
                            Spacer()
                            
                            Image(systemName: "ellipsis")
                                .foregroundColor(CustomColors.LightGray)
                                .padding(.trailing, 5.0)
                                .onTapGesture {
                                    showingOptions.toggle()
                                }
                        }
                        .padding(.horizontal, 18.0)
                        .padding(.top, 18.0)
                        .padding(.bottom, 8.0)
                        
                        Divider()
                            .padding(.horizontal, 15.0)
                        
                        
                        // Rows of sensors
                        
                        let sensorSize = 60
                        let sensorRowCount = 5
                        let horizontalSpacing = 15
                        let availableRowSpace = UIScreen.main.bounds.width - CGFloat(2 * horizontalSpacing + sensorSize * sensorRowCount)
                        let sensorSpacing = availableRowSpace / CGFloat(sensorRowCount - 1)
                                                
                        let x = print(sensorSpacing)
                        VStack(spacing: sensorSpacing) {
                            // row 1
                            HStack(spacing: sensorSpacing) {
                                ForEach(0..<5, id: \.self) { i in
                                    if i < (SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count) {
                                        let d = SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i]
//                                        let x = print("Timestamp:  \(d.id)\(d.lastTimestamp), \(d.lastTimestamp.timeIntervalSinceNow)")
                                        
//                                        if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].lastTimestamp!.timeIntervalSinceNow < -300 {
//                                            SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].connected = false
//                                            d.connected = false
//                                        }
                                        
                                        ZStack {
                                            
                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].threat == Threat.Red {
                                                Circle()
                                                    .fill(CustomColors.TorchRed)
                                                    .frame(width: 60.0, height: 60.0)
                                                Image("FireWhite")
                                                    .resizable()
                                                    .frame(width: 32, height: 32)
                                                
                                                Button {
                                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                    impactMed.impactOccurred()
                                                    
//                                                    selectedMarker = annotations.first(where: { marker in
//                                                        marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                    })
                                                    for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                        if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                            selectedDetectorIndex = i
                                                            break
                                                        }
                                                    }
                                                    sensorTapped = true
                                                    selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                        detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                    })
                                                    sessionManager.selectedDetectorIndex = i
                                                    showDetectorDetails = true
                                                    
                                                    zoomLevel = 15
                                                } label: {
                                                    Circle()
                                                        .fill(Color.clear)
                                                        .frame(width: 60.0, height: 60.0)
                                                }
                                            } else if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].threat == Threat.Yellow {
                                                Circle()
                                                    .fill(CustomColors.WarningYellow)
                                                    .frame(width: 60.0, height: 60.0)
                                                Image("FireWhite")
                                                    .resizable()
                                                    .frame(width: 32, height: 32)
                                                Button {
                                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                    impactMed.impactOccurred()
                                                    
//                                                    selectedMarker = annotations.first(where: { marker in
//                                                        marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                    })
                                                    for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                        if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                            selectedDetectorIndex = i
                                                            break
                                                        }
                                                    }
                                                    sensorTapped = true
                                                    selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                        detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                    })
                                                    sessionManager.selectedDetectorIndex = i
                                                    showDetectorDetails = true
                                                    
                                                    zoomLevel = 15
                                                } label: {
                                                    Circle()
                                                        .fill(Color.clear)
                                                        .frame(width: 60.0, height: 60.0)
                                                }
//                                                SessionManager.shared.latestTimestampDict[SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id]
                                            } else if d.connected == false || (SessionManager.shared.latestTimestampDict.keys.contains(SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id) &&
                                                                               SessionManager.shared.latestTimestampDict[SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id]!.timeIntervalSinceNow < -300) {
//                                            } else if d.connected == false || SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].lastTimestamp.timeIntervalSinceNow < -300 {
                                                Circle()
                                                    .fill(Color(red: 0.67, green: 0.72, blue: 0.73))
                                                    .frame(width: 60.0, height: 60.0)
                                                Image(systemName: "wifi.slash")
                                                    .resizable()
                                                    .frame(width: 22, height: 22 / 1.07)
                                                    .foregroundColor(.white)
                                                Button {
                                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                    impactMed.impactOccurred()
                                                    
//                                                    selectedMarker = annotations.first(where: { marker in
//                                                        marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                    })
                                                    sensorTapped = true
                                                    for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                        if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                            selectedDetectorIndex = i
                                                            break
                                                        }
                                                    }
                                                    selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                        detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                    })
                                                    sessionManager.selectedDetectorIndex = i
                                                    showDetectorDetails = true
                                                    
                                                    zoomLevel = 15
                                                } label: {
                                                    Circle()
                                                        .fill(Color.clear)
                                                        .frame(width: 60.0, height: 60.0)
                                                }
                                            } else {
                                                Circle()
                                                    .fill(colorScheme == .dark ? Color(red: 0.27, green: 0.32, blue: 0.33) : CustomColors.NormalSensorGray)
                                                    .frame(width: 60.0, height: 60.0)
                                                Text("\(i + 1)")
                                                    .font(Font.custom("Manrope-Medium", size: 18.0))
                                                    .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                                                Button {
                                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                    impactMed.impactOccurred()
                                                    
//                                                    selectedMarker = annotations.first(where: { marker in
//                                                        guard let userData = marker.userData as? String else {
//                                                            return false
//                                                        }
//                                                        return userData == sessionManager.selectedProperty!.detectors[i].id
//                                                    })
                                                    sensorTapped = true
                                                    for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                        if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                            selectedDetectorIndex = i
                                                            break
                                                        }
                                                    }
                                                    selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                        detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                    })
                                                    sessionManager.selectedDetectorIndex = i
                                                    showDetectorDetails = true
                                                    
                                                    zoomLevel = 15
                                                } label: {
                                                    Circle()
                                                        .fill(Color.clear)
                                                        .frame(width: 60.0, height: 60.0)
                                                }
                                            }
                                            
                                        }
                                    } else if (i == SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count) {
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

//                                            Circle()
//                                                .fill(Color.clear)
//                                                .frame(width: 5, height: 5)
                                        }
                                    } else {
                                        ZStack {
                                            Circle()
                                                .fill(Color.clear)
                                                .frame(width: 60.0, height: 60.0)
                                        }
                                           
                                    }
                                                                    
                                }
                            }
                            
                            // row 2
    //
                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count >= 5 {
                                HStack(spacing: sensorSpacing) {
                                    ForEach(5..<10, id: \.self) { i in
                                        if i < (SessionManager.shared.selectedProperty?.detectors.count)! {
                                            let d = SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i]
                                            ZStack {
                                                
                                                if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].threat == Threat.Red {
                                                    Circle()
                                                        .fill(CustomColors.TorchRed)
                                                        .frame(width: 60.0, height: 60.0)
                                                    Image("FireWhite")
                                                        .resizable()
                                                        .frame(width: 32, height: 32)

                                                    Button {
                                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                        impactMed.impactOccurred()
                                                        
//                                                        selectedMarker = annotations.first(where: { marker in
//                                                            marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                        })
                                                        for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                                selectedDetectorIndex = i
                                                                break
                                                            }
                                                        }
                                                        sensorTapped = true
                                                        selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                            detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                        })
                                                        sessionManager.selectedDetectorIndex = i
                                                        showDetectorDetails = true
                                                        
                                                        zoomLevel = 15
                                                    } label: {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 60.0, height: 60.0)
                                                    }
                                                } else if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].threat == Threat.Yellow {
                                                    Circle()
                                                        .fill(CustomColors.WarningYellow)
                                                        .frame(width: 60.0, height: 60.0)
                                                    Image("FireWhite")
                                                        .resizable()
                                                        .frame(width: 32, height: 32)
                                                    Button {
                                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                        impactMed.impactOccurred()
                                                        
//                                                        selectedMarker = annotations.first(where: { marker in
//                                                            marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                        })
                                                        for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                                selectedDetectorIndex = i
                                                                break
                                                            }
                                                        }
                                                        sensorTapped = true
                                                        selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                            detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                        })
                                                        sessionManager.selectedDetectorIndex = i
                                                        showDetectorDetails = true
                                                        
                                                        zoomLevel = 15
                                                    } label: {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 60.0, height: 60.0)
                                                    }
                                                } else if d.connected == false || SessionManager.shared.latestTimestampDict[SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id]!.timeIntervalSinceNow < -300 {
                                                    Circle()
                                                        .fill(Color(red: 0.67, green: 0.72, blue: 0.73))
                                                        .frame(width: 60.0, height: 60.0)
                                                    Image(systemName: "wifi.slash")
                                                        .resizable()
                                                        .frame(width: 22, height: 22 / 1.07)
                                                        .foregroundColor(.white)
                                                    Button {
                                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                        impactMed.impactOccurred()
                                                        
//                                                        selectedMarker = annotations.first(where: { marker in
//                                                            marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                        })
                                                        for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                                selectedDetectorIndex = i
                                                                break
                                                            }
                                                        }
                                                        sensorTapped = true
                                                        selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                            detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                        })
                                                        sessionManager.selectedDetectorIndex = i
                                                        showDetectorDetails = true
                                                        
                                                        zoomLevel = 15
                                                    } label: {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 60.0, height: 60.0)
                                                    }
                                                } else {
                                                    Circle()
                                                        .fill(colorScheme == .dark ? Color(red: 0.27, green: 0.32, blue: 0.33) : CustomColors.NormalSensorGray)
                                                        .frame(width: 60.0, height: 60.0)
                                                    Text("\(i + 1)")
                                                        .font(Font.custom("Manrope-Medium", size: 18.0))
                                                        .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                                                    Button {
                                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                        impactMed.impactOccurred()
                                                        
//                                                        selectedMarker = annotations.first(where: { marker in
//                                                            marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                        })
                                                        
                                                        for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                                selectedDetectorIndex = i
                                                                break
                                                            }
                                                        }
                                                        sensorTapped = true
                                                        selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                            detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                        })
                                                        sessionManager.selectedDetectorIndex = i
                                                        showDetectorDetails = true
                                                        
                                                        zoomLevel = 15
                                                    } label: {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 60.0, height: 60.0)
                                                    }
                                                }
                                                                                        
                                            }
                                        } else if (i == SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count) {
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

    //                                            Circle()
    //                                                .fill(Color.clear)
    //                                                .frame(width: 5, height: 5)
                                            }
                                        } else {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.clear)
                                                    .frame(width: 60.0, height: 60.0)
                                            }
                                        }
                                    }
                                }
                            }

                            // row 3
                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count >= 10 {
                                HStack(spacing: sensorSpacing) {
                                    ForEach(10..<15, id: \.self) { i in
                                                                        
                                        if i < (SessionManager.shared.selectedProperty?.detectors.count)! {
                                            let d = SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i]
                                            ZStack {
                                                
                                                if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].threat == Threat.Red {
                                                    Circle()
                                                        .fill(CustomColors.TorchRed)
                                                        .frame(width: 60.0, height: 60.0)
                                                    Image("FireWhite")
                                                        .resizable()
                                                        .frame(width: 32, height: 32)

                                                    Button {
                                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                        impactMed.impactOccurred()
                                                        
//                                                        selectedMarker = annotations.first(where: { marker in
//                                                            marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                        })
                                                        for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                                selectedDetectorIndex = i
                                                                break
                                                            }
                                                        }
                                                        selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                            detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                        })
                                                        sensorTapped = true
                                                        sessionManager.selectedDetectorIndex = i
                                                        showDetectorDetails = true
                                                        
                                                        zoomLevel = 15
                                                    } label: {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 60.0, height: 60.0)
                                                    }
                                                } else if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].threat == Threat.Yellow {
                                                    Circle()
                                                        .fill(CustomColors.WarningYellow)
                                                        .frame(width: 60.0, height: 60.0)
                                                    Image("FireWhite")
                                                        .resizable()
                                                        .frame(width: 32, height: 32)
                                                    Button {
                                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                        impactMed.impactOccurred()
                                                        
//                                                        selectedMarker = annotations.first(where: { marker in
//                                                            marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                        })
                                                        for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                                selectedDetectorIndex = i
                                                                break
                                                            }
                                                        }
                                                        sensorTapped = true
                                                        selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                            detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                        })
                                                        sessionManager.selectedDetectorIndex = i
                                                        showDetectorDetails = true
                                                        
                                                        zoomLevel = 15
                                                    } label: {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 60.0, height: 60.0)
                                                    }
                                                } else if d.connected == false || SessionManager.shared.latestTimestampDict[SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id]!.timeIntervalSinceNow < -300 {
                                                    Circle()
                                                        .fill(Color(red: 0.67, green: 0.72, blue: 0.73))
                                                        .frame(width: 60.0, height: 60.0)
                                                    Image(systemName: "wifi.slash")
                                                        .resizable()
                                                        .frame(width: 22, height: 22 / 1.07)
                                                        .foregroundColor(Color.white)
                                                    Button {
                                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                        impactMed.impactOccurred()
//                                                        selectedMarker = annotations.first(where: { marker in
//                                                            marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                        })
                                                        for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                                selectedDetectorIndex = i
                                                                break
                                                            }
                                                        }
                                                        sensorTapped = true
                                                        selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                            detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                        })
                                                        showDetectorDetails = true
                                                        
                                                        zoomLevel = 15
                                                    } label: {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 60.0, height: 60.0)
                                                    }
                                                } else {
                                                    Circle()
                                                        .fill(colorScheme == .dark ? Color(red: 0.27, green: 0.32, blue: 0.33) : CustomColors.NormalSensorGray)
                                                        .frame(width: 60.0, height: 60.0)
                                                    Text("\(i + 1)")
                                                        .font(Font.custom("Manrope-Medium", size: 18.0))
                                                        .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                                                    Button {
                                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                                        impactMed.impactOccurred()
                                                        
//                                                        selectedMarker = annotations.first(where: { marker in
//                                                            marker.userData as! String == sessionManager.selectedProperty!.detectors[i].id
//                                                        })
                                                        for i in 0..<SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count {
                                                            if SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[i].id == sessionManager.selectedProperty!.detectors[i].id {
                                                                selectedDetectorIndex = i
                                                                break
                                                            }
                                                        }
                                                        sensorTapped = true
                                                        selectedDetector = sessionManager.selectedProperty!.detectors.first(where: { detector in
                                                            detector.id == sessionManager.selectedProperty!.detectors[i].id
                                                        })
                                                        sessionManager.selectedDetectorIndex = i
                                                        showDetectorDetails = true
                                                        
                                                        zoomLevel = 15
                                                    } label: {
                                                        Circle()
                                                            .fill(Color.clear)
                                                            .frame(width: 60.0, height: 60.0)
                                                    }
                                                }
                                                                                        
                                            }
                                        } else if (i == SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.count) {
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

    //                                            Circle()
    //                                                .fill(Color.clear)
    //                                                .frame(width: 5, height: 5)
                                            }
                                        } else {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.clear)
                                                    .frame(width: 60.0, height: 60.0)
                                            }
                                               
                                        }
                                                                        
                                    }
                                }
                            }
                        }
                        .padding(.top, 10.0)
                        .padding(.bottom, 20.0)
                        
                        if newDetector != nil {
                            HStack {
                                Spacer()
                                
                                let verb = newDetector?.coordinate == nil ? "Set" : "Change"
                                
                                Button(action: {
                                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                    impactMed.impactOccurred()
                                    
                                    self.isConfirmingLocation = true
                                    var pointAnnotation = PointAnnotation(id: newDetector!.id, coordinate: self.pin)
                                    var annotationIcon = "NewSensorIcon\(newDetector!.sensorIdx!)"
                                    var annotationImage = UIImage(named: annotationIcon)!
                                    annotationImage.scale(newWidth: 1.0)
                                    pointAnnotation.image = .init(image: annotationImage, name: annotationIcon)
                        //            pointAnnotation.image?.image.scale = 4.0
                                    pointAnnotation.iconAnchor = .bottom
                                    pointAnnotation.iconSize = 0.25
                                    pointAnnotation.iconOffset = [40, 0]
                                    
                                    self.annotations.append(pointAnnotation)
                                    
                                }) {
                                    Text("\(verb) the position for new sensor")
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
                                
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        }
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .overlay(GeometryReader { geo in
                Rectangle().fill(Color.clear)
                    .onAppear {
                        self.size = geo.size
                        self.mapOffset = geo.size
                    }.onChange(of: geo.size) { updatedSize in
                        self.size = updatedSize
                        self.mapOffset = geo.size
                    }
            })
        }
    }
}

struct AddDetectorConfirmLocationOverlayView: View {
    @Environment(\.colorScheme) var colorScheme
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
//    let property: Property
        
    @Binding var size: CGSize
    @Binding var annotations: [PointAnnotation]
    @Binding var pin: CLLocationCoordinate2D
    @Binding var newDetector: Detector?
    @Binding var isConfirmingLocation: Bool
    @State var nextButtonColor: Color = Color(red: 0.18, green: 0.21, blue: 0.22)
    @State var nextButtonEnabled: Bool = true
    @Binding var needsLocationPin: Bool
//    @ObservedObject var sessionManager: SessionManager
    @StateObject var sessionManager = SessionManager.shared
    
    @Binding var newDetectorIndex: Int
    
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
                                
//                                sessionManager.setDetectorCoordinate(detector: newDetector!, coordinate: self.pin)
                                newDetector?.coordinate = self.pin
                                SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[newDetectorIndex].coordinate = self.pin
                                print("Pin position: \(self.pin)")
                                print("Set coordinate: \(newDetector?.coordinate)")
                                
                                var pointAnnotation = PointAnnotation(id: newDetector!.id, coordinate: self.pin)
                                var annotationIcon = "NewSensorIcon\(newDetector!.sensorIdx!)"
                                
                                var annotationImage = UIImage(named: annotationIcon)!
                                annotationImage.scale(newWidth: 1.0)
                                pointAnnotation.image = .init(image: annotationImage, name: annotationIcon)
                    //            pointAnnotation.image?.image.scale = 4.0
                                pointAnnotation.iconAnchor = .bottom
                                pointAnnotation.iconSize = 0.25
                                pointAnnotation.iconOffset = [40, 0]
                                
                                self.annotations.append(pointAnnotation)
                                
//                                let sensorMarker = GMSMarker(position: self.pin)
//                                sensorMarker.userData = newDetector!.id
//                                let assetName = "NewSensorIcon\(newDetector!.sensorIdx!)"
//                                print("Got asset name: \(assetName)")
//                                var markerImage = UIImage(named: assetName)
//                                markerImage = UIImage(cgImage: (markerImage?.cgImage)!, scale: 4.0, orientation: (markerImage?.imageOrientation)!)
//                                sensorMarker.icon = markerImage
                                
//                                for i in 0..<self.annotations.count {
//                                    guard let id = self.annotations[i].id else {
//                                        continue
//                                    }
//
//                                    if id == newDetector!.id {
//                                        print("\(i) markers count before \(self.annotations.count)")
//                                        self.annotations.remove(at: i)
////                                        self.markers[i].userData = "remove"
//                                        print("\(i) markers count after \(self.annotations.count)")
//
//                                        break
//                                    }
//                                }
//
//                                self.annotations.append(sensorMarker)
                                
                                SessionManager.shared.registerDevice(property: SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex], detector: SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors[newDetectorIndex])
                                
//                                SessionManager.shared.properties[SessionManager.shared.selectedPropertyIndex].detectors.append(newDetector!)
                                self.isConfirmingLocation = false
                                self.newDetector = nil
                                self.needsLocationPin = false
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
                            
                            Spacer()
                        }
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                for i in 0..<self.annotations.count {
                                    if self.annotations[i].id as! String == newDetector!.id {
                                        print("\(i) markers count before \(self.annotations.count)")
//                                        self.an[i].map = nil
                                        self.annotations.remove(at: i)
//                                        self.markers[i].userData = "remove"
                                        print("\(i) markers count after \(self.annotations.count)")
                                        
                                        break
                                    }
                                }
                                
//                                for i in 0..<(SessionManager.shared.selectedProperty?.detectors.count)! {
//                                    if self.annotations[i].id as! String == newDetector!.id {
//                                        SessionManager.shared.selectedProperty?.detectors.remove(at: i)
//                                        break
//                                    }
//                                }
                                
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

struct BackButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedDetector: Detector?
    @Binding var showDetectorDetails: Bool
//    @Binding var mapOffset: CGSize
    @Binding var dragOffset: CGSize
    
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                .frame(width: 48.0, height: 48.0)
            Image(systemName: "chevron.backward")
                .frame(width: 48.0, height: 48.0)
                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                                
                withAnimation(.easeIn(duration: 0.1)) {
                    self.dragOffset = .zero
                }
                showDetectorDetails = false
                selectedDetector = nil
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray, radius: 15.0)
    }
}

struct PropertiesBackButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showDetectorDetails: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                .frame(width: 48.0, height: 48.0)
            Image(systemName: "chevron.backward")
                .frame(width: 48.0, height: 48.0)
                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                withAnimation {
                    SessionManager.shared.appState = .properties
                }
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray, radius: 15.0)
    }
}

struct HamburgerButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var hideOverlay: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                .frame(width: 48.0, height: 48.0)
            Image(systemName: "line.3.horizontal")
                .frame(width: 48.0, height: 48.0)
                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                withAnimation {
//                    hideOverlay = true
                }
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray, radius: 15.0)
    }
}

struct ZoomInButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var zoomLevel: CGFloat
    @Binding var zoomChanged: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                .frame(width: 48.0, height: 48.0)
            Image(systemName: "plus")
                .frame(width: 48.0, height: 48.0)
                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                zoomLevel = min(zoomLevel + 1, 20)
                zoomChanged = true
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray, radius: 15.0)
    }
}

struct ZoomOutButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var zoomLevel: CGFloat
    @Binding var zoomChanged: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                .frame(width: 48.0, height: 48.0)
            Image(systemName: "minus")
                .frame(width: 48.0, height: 48.0)
                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                zoomLevel = max(zoomLevel - 1, 1)
                zoomChanged = true
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray, radius: 15.0)
    }
}

struct LayersButton: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                .frame(width: 48.0, height: 48.0)
            Image("Layers")
                .resizable()
                .renderingMode(.template)
                .frame(width: 20.0, height: 20.0)
                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray.opacity(0.5), radius: 15.0)
    }
}

struct LocationButton: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var moveToUserTapped: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                .frame(width: 48.0, height: 48.0)
            Image("Location")
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                moveToUserTapped = true
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray.opacity(0.5), radius: 15.0)
    }
}

struct HalfCircleShape : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addArc(center: CGPoint(x: rect.minX, y: rect.midY), radius: rect.height , startAngle: .degrees(90), endAngle: .degrees(270), clockwise: true)
        return path
    }
}

struct BatteryView : View {
    var batteryLevel: Double
    
    var body: some View {
        // UIDevice.current.batteryLevel always returns -1, and I don't know why. so here's a value for you to preview
//        let batteryLevel = 0.4
        GeometryReader { geo in
            HStack(spacing: 1) {
                
                GeometryReader { rectangle in
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(lineWidth: 1)
                        .foregroundColor(Color.BatteryLevel(batteryLevel: batteryLevel))
                    RoundedRectangle(cornerRadius: 2)
                        .padding(1)
                        .frame(width: rectangle.size.width - (rectangle.size.width * (1 - (batteryLevel / 100.0))))
                        .foregroundColor(Color.BatteryLevel(batteryLevel: batteryLevel))
                }
                HalfCircleShape()
                .frame(width: geo.size.width / 7, height: geo.size.height / 7)
                .foregroundColor(Color.BatteryLevel(batteryLevel: batteryLevel))
                
            }
//            .padding(.leading)
        }
    }
}

extension Color {
    static func BatteryLevel(batteryLevel: Double) -> Color {
        print("battery: \(batteryLevel)")
        var battery = batteryLevel / 100.0
        print("battery: \(battery)")
        switch battery {
            // returns red color for range %0 to %20
            case 0...0.2:
                return CustomColors.TorchRed
            // returns yellow color for range %20 to %50
            case 0.2...0.5:
                return CustomColors.WarningYellow
            // returns green color for range %50 to %100
            case 0.5...1.0:
                return CustomColors.GoodGreen
            default:
                return Color.clear
        }
    }
    
//    static var BatteryLevel : Color {
//        let batteryLevel = 0.4
////        print(batteryLevel)
//        switch batteryLevel {
//            // returns red color for range %0 to %20
//            case 0...0.2:
//                return Color.red
//            // returns yellow color for range %20 to %50
//            case 0.2...0.5:
//                return Color.yellow
//            // returns green color for range %50 to %100
//            case 0.5...1.0:
//                return Color.green
//            default:
//                return Color.clear
//        }
//    }
}
//
//struct PropertyIconView: View {
//    var propertyName: String
//
//    var body: some View {
//        ZStack {
//            Rectangle()
//                .fill(Color.red)
//                .frame(width: 100, height: 100)
//                .fixedSize(horizontal: true, vertical: false)
//                .shadow(color: Color.gray,radius: 5.0)
//
//            HStack {
//                Image("PropertyIcon")
//                    .resizable()
//                    .frame(width: 20, height: 20)
//
//                Text(propertyName)
//            }
//        }
//    }
//}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
////        MapView()
//    }
//}
