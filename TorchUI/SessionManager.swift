//
//  SessionManager.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/6/23.
//

import Foundation
import CoreLocation

enum AppState {
    case properties
    case viewProperty
}

struct AlertModel: Identifiable {
    var id = UUID()
    
//    var propertyIndex: Int
//    var detectorIndex: Int
    var property: Property
    var detector: Detector
    var threat: Threat
}

final class SessionManager: ObservableObject {    
    
    static var shared = SessionManager()
    @Published var latestTimestampDict: [String : Date] = [:]
    @Published var properties: [Property] = []
    @Published var selectedProperty: Property?
    @Published var selectedPropertyIndex = 0
    @Published var selectedDetectorIndex = 0
    
    @Published var newProperty: Property?
//    @Published var addingNewDetector: Property?
    
    @Published var appState: AppState = .properties
    
    @Published var alerts: [AlertModel] = []
    
    @Published var propertiesLoaded: Bool = false
    @Published var firstTransition: Bool = true
    @Published var showSplashScreen = true
    @Published var firstTimeLoaded: Bool = false
    private let RED_THRESHOLD = 80
    private let YELLOW_THRESHOLD = 60
    @Published var unparsedProperties = 0
    
    @Published var deletedDetectors: Set<String> = []
    @Published var deletedProperties: Set<String> = []
    
    @Published var loadingProperties = [
        Property(id: "0", propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: ""),
        Property(id: "1", propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: ""),
        Property(id: "2", propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: ""),
        Property(id: "3", propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: "")
    ]
    
    init() {
//        dummyUserSetup()
    }
    
    func clearData() {
        print("setting properties empty cd")
        self.propertiesLoaded = false
        self.appState = .properties
        self.properties = []
        self.selectedProperty = nil
        self.newProperty = nil
    }
    
    func clearProperties() {
        print("setting properties empty cp")
        self.propertiesLoaded = false
        self.properties = []
        self.alerts = []
    }
    
    func dummyUserSetup() {
        let property = Property(id: "0", propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: "Property", detectors: [
            Detector(id: "1", deviceName: "Backyard", deviceBattery: 83.0,
                     measurements: ["fire_rating" : "23"],
                     coordinate: CLLocationCoordinate2D(latitude: 37.656434, longitude: -121.972)),
            Detector(id: "2", deviceName: "Frontyard", deviceBattery: 91.0,
                     measurements: ["fire_rating" : "81"],
                     coordinate: CLLocationCoordinate2D(latitude: 37.655521, longitude: -121.962646), threat: Threat.Red),
            Detector(id: "3", deviceName: "Frontyard", deviceBattery: 74.0,
                     measurements: ["fire_rating" : "77"],
                     coordinate: CLLocationCoordinate2D(latitude: 37.646415, longitude: -121.963075), threat: Threat.Yellow),
            Detector(id: "4", deviceName: "Backyard", deviceBattery: 87.0,
                     measurements: ["fire_rating" : "17"],
                     coordinate: CLLocationCoordinate2D(latitude: 37.644036, longitude: -121.979566)),
            Detector(id: "5", deviceName: "Frontyard", deviceBattery: 56.0,
                     measurements: ["fire_rating" : "96"],
                     coordinate: CLLocationCoordinate2D(latitude: 37.648386, longitude: -121.969259), threat: Threat.Red),
            Detector(id: "6", deviceName: "Frontyard", deviceBattery: 41.0,
                     measurements: ["fire_rating" : "46"],
                     coordinate: CLLocationCoordinate2D(latitude: 37.647842, longitude: -121.962045)),
            
            // random from here on
            Detector(id: "7", deviceName: "Backyard", deviceBattery: 87.0, coordinate: CLLocationCoordinate2D(latitude: 37.7576, longitude: -122.4194)),
            Detector(id: "8", deviceName: "Frontyard", deviceBattery: 63.0, coordinate: CLLocationCoordinate2D(latitude: 47.6131742, longitude: -122.4824903)),
            Detector(id: "9", deviceName: "Frontyard", deviceBattery: 63.0, coordinate: CLLocationCoordinate2D(latitude: 1.3440852, longitude: 103.6836164)),
            Detector(id: "10", deviceName: "Backyard", deviceBattery: 87.0, coordinate: CLLocationCoordinate2D(latitude: -33.8473552, longitude: 150.6511076)),
            Detector(id: "11", deviceName: "Frontyard", deviceBattery: 63.0, coordinate: CLLocationCoordinate2D(latitude: 35.6684411, longitude: 139.6004407)),
            Detector(id: "12", deviceName: "Frontyard", deviceBattery: 63.0, coordinate: CLLocationCoordinate2D(latitude: 35.02, longitude: 136)),
            Detector(id: "13", deviceName: "Backyard", deviceBattery: 87.0, coordinate: CLLocationCoordinate2D(latitude: 37.7576, longitude: -122.4194)),
            Detector(id: "14", deviceName: "Frontyard", deviceBattery: 63.0, coordinate: CLLocationCoordinate2D(latitude: 47.6131742, longitude: -122.4824903), connected: false)
        ])
        
        self.properties.append(property)
        
        for i in 0..<10 {
            self.properties.append(property)
        }
        
        self.selectedProperty = property
        
        self.newProperty = Property(id: "1", propertyName: "Mom's house", propertyAddress: "2237 Kamp Court, Pleasanton, CA 94588", propertyImage: "https://maps.googleapis.com/maps/api/staticmap?key=AIzaSyBevmebTmlyD-kftwvRqqRItgh07CDiwx0&size=180x180&scale=2&maptype=satellite&zoom=19&center=2237 Kamp Court, Pleasanton, CA 94588")
    }
    
    func createUserData(email: String) {
        // print("Creating user data")
        
        let req = SocketRequest(route: "createUserDB",
                                data: [
                                    "user_id": AuthenticationManager.shared.authUser.userId,
                                    "email": email
                                ],
                                completion: { data in
            // print("[CreateUserData] Received data: \(data)")
            AuthenticationManager.shared.authState = .authenticated            
        })
        
        // Send request through socket
        WebSocketManager.shared.sendData(socketRequest: req)
    }
    
    func loadUserProperties() {
//        self.propertiesLoaded = false
        
        // print("[SessionManager] Loading user properties")
        
        let userID = AuthenticationManager.shared.authUser.userId
        
        
        let req = SocketRequest(route: "getPropertiesDevicesData",
                                data: [
                                    "user_id": userID
                                ],
                                completion: { data in
            // print("[LoadUserProperties] Received data.")
            
            guard let result = data["result"] as? [String: Any] else {
                // print("[LoadUserProperties] Couldn't extract result")
                DispatchQueue.main.async {
                    print("couldn't parse:", data)
                    guard let resultString = data["result"] as? String else {
                        self.propertiesLoaded = true
                        return
                    }
                    
                    if resultString.contains("properties not found") {
                        self.properties = []
                        self.alerts = []
                    }
                    
//                    self.properties = []
//                    self.alerts = []
                    self.propertiesLoaded = true
                    self.loadUserProperties()
                }
                return
            }
            
            guard let properties = result["properties"] as? [String : [String: Any]] else {
                // print("[LoadUserProperties] Couldn't extract properties")
                DispatchQueue.main.async {
                    print("couldn't parse:", data)
//                    if data["res"]
//                    self.properties = []
//                    self.alerts = []
                    self.propertiesLoaded = true
                    self.loadUserProperties()
                }
                return
            }
            
//            print("Got res: \(properties)")
            
            if self.firstTimeLoaded && self.properties.count == properties.count {
                self.updateDevices(properties: properties)
            } else {
                if (self.newProperty == nil) {
                    print("DIFF PROPERTIES, \(self.properties.count), \(properties.count), \(self.properties), \(properties)")
                    self.clearProperties()
                    var deletedProperties = 0
                    for (id, property) in properties {
                        // print("Fresh Property: \(id) \(property)")
                        if (self.deletedProperties.contains(id)) {
                            deletedProperties += 1
                            continue
                        }
                        self.parseProperty(id: id, property: property)
                    }
                    
                    self.unparsedProperties = properties.count - deletedProperties
                    DispatchQueue.main.async {
                        self.propertiesLoaded = true
                        self.firstTimeLoaded = true
                    }
                }
            }
            
            self.loadUserProperties()
        })
        
        // Send request through socket
        WebSocketManager.shared.sendData(socketRequest: req)
    }
    
    
    func uploadNewProperty() {
        // print("Uploading new property")
        
        let userID = AuthenticationManager.shared.authUser.userId
        let property = self.newProperty!
        
        let req = SocketRequest(route: "createPropertyDB",
                                data: [
                                    "user_id": userID,
                                    "property_name": property.propertyName,
                                    "property_address": property.propertyAddress,
                                    "property_image": property.propertyImage,
                                ],
                                completion: { data in
            // print("[UploadNewProperty] Received data: \(data)")
                        
            guard let result = data["result"] as? [String: Any] else {
                // print("[UploadNewProperty] Couldn't extract result")
                return
            }
            
            guard let property_id = result["property_id"] as? String else {
                // print("[UploadNewProperty] Failed to create property in backend")
                return
            }
            
            self.newProperty!.id = property_id
//            // print("Set new property id: \(self.newProperty!.id) from \(self)")
            self.properties.append(self.newProperty!)
            self.properties[self.properties.count - 1].loadingData = true
            self.selectedPropertyIndex = self.properties.count - 1
            print("Set property index: \(self.selectedPropertyIndex) \(self.properties.count)")
        })
        
        // Send request through socket
        WebSocketManager.shared.sendData(socketRequest: req)
    }
    
    func updateDevices(properties: [String : [String: Any]]) {
        
        // print("Updating devices")
        
        var redAlert: AlertModel? = nil
        var yellowAlert: AlertModel? = nil
        var alertsAdded: Bool = false
        
        print("Got updated properties: \(properties.keys)")
        
        for (id, new_property) in properties {
            print("Checking property \(id), del \(self.deletedProperties)")
            if self.deletedProperties.contains(id) {
                print("Ignoring new property \(id)")
                continue
            }
            
            for i in 0..<self.properties.count {
//            for existing_property in self.properties {
                if self.properties[i].id == id {
                    // We found property with same ID, update device measurements
                    guard let devices = new_property["devices"] as? [[String: Any]] else {
                        return
                    }
                                        
                    var propertyStatus = "All sensors are normal"
                    
//                    print("Property before: \(self.properties[i])")
                    for j in 0..<self.properties[i].detectors.count {
                        var flag = false
                        for new_device in devices {
                            if self.properties[i].detectors[j].id == new_device["device_id"] as! String {
                                flag = true
                                let deviceID = new_device["device_id"] as! String
                                let deviceName = new_device["device_name"] as! String
                                let deviceMeasurements = new_device["measurements"] as! [String: Any]
                                let propertyAddress = new_device["property_address"] as! String
                                let latitude = new_device["latitude"] as! Double
                                let longitude = new_device["longitude"] as! Double
                                
                                var deviceBattery = 0.0
                                var fireRatingNumber = 0
                                var fireRating = "0"
                                var temperature = "0"
                                var humidity = "0"
                                var thermalStatus = Threat.Green
                                var spectralStatus = Threat.Green
                                var smokeStatus = Threat.Green
                                var overallStatus = Threat.Green
                                var lastTimestamp = Date()
                                
                                
                                if let batteryString = deviceMeasurements["battery"] as? String {
                                    deviceBattery = Double(batteryString)!
                                }
                                if let fireRatingString = deviceMeasurements["risk_probability"] as? String {
                                    fireRatingNumber = Int(Double(fireRatingString)!)
                                    fireRating = String(fireRatingNumber)
                                }
                                if let temperatureString = deviceMeasurements["temperature"] as? String {
                                    let tmp = Int(Double(temperatureString)!)
                                    temperature = String(tmp)
                                }
                                
                                if let humidityString = deviceMeasurements["humidity"] as? String {
                                    let tmp = Int(Double(humidityString)!)
                                    humidity = String(tmp)
                                }
                                
                                if let thermalStatusString = deviceMeasurements["thermal_status"] as? String {
                                    let tmp = String(thermalStatusString)
                                    if tmp == "YELLOW" {
                                        thermalStatus = Threat.Yellow
                                    } else if tmp == "RED" {
                                        thermalStatus = Threat.Red
                                    }
                                }
                                
                                if let spectralStatusString = deviceMeasurements["spectral_status"] as? String {
                                    let tmp = String(spectralStatusString)
                                    if tmp == "YELLOW" {
                                        spectralStatus = Threat.Yellow
                                    } else if tmp == "RED" {
                                        spectralStatus = Threat.Red
                                    }
                                }
                                
                                if let smokeStatusString = deviceMeasurements["smoke_status"] as? String {
                                    let tmp = String(smokeStatusString)
                                    // print("SmokeStatusString \(tmp)")
                                    if tmp == "YELLOW" {
                                        smokeStatus = Threat.Yellow
                                    } else if tmp == "RED" {
                                        smokeStatus = Threat.Red
                                    }
                                }
                                
                                if let timeString = deviceMeasurements["time"] as? String {
                                    let timestamp = String(timeString)

                                    let formatter = DateFormatter()
                                    formatter.timeZone = TimeZone(abbreviation: "UTC")

                                    // Set the format to match your timestamp
                                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSSSS"

                                    if let date = formatter.date(from: timestamp) {
                                        lastTimestamp = date
                                        // print("Converted timestamp from \(timestamp) to \(lastTimestamp)")
                                        // Now you can use this 'date' object as needed in your app
                                    } else {
                                        // print("Failed to parse date")
                                    }

                                }
                                
                                var redFlag = false
                                var yellowFlag = false
                                if let overallStatusString = deviceMeasurements["overall_status"] as? String {
                                    let tmp = String(overallStatusString)
                                    // print("[OverallStatusString] \(tmp)")
                                    if tmp == "YELLOW" {
                                        overallStatus = Threat.Yellow
                                        propertyStatus = "Warning"
                                        yellowFlag = true
                                    } else if tmp == "RED" {
                                        overallStatus = Threat.Red
                                        propertyStatus = "Red alert"
                                        redFlag = true
                                    }
                                }
                                
                                if redFlag {
                                    redAlert = AlertModel(property: self.properties[i], detector: self.properties[i].detectors[j], threat: Threat.Red)
//                                    print("RED FLAG TRUE")
                                }
                                if yellowFlag {
                                    yellowAlert = AlertModel(property: self.properties[i], detector: self.properties[i].detectors[j], threat: Threat.Yellow)
//                                    print("YELLOW FLAG TRUE")
                                }
                                
                                self.properties[i].detectors[j].measurements["fire_rating"] = fireRating
                                self.properties[i].detectors[j].measurements["temperature"] = temperature
                                self.properties[i].detectors[j].measurements["humidity"] = humidity
                                self.properties[i].detectors[j].spectralStatus = spectralStatus
                                self.properties[i].detectors[j].smokeStatus = smokeStatus
                                self.properties[i].detectors[j].thermalStatus = thermalStatus
                                self.properties[i].detectors[j].coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                                self.properties[i].detectors[j].deviceBattery = deviceBattery
//                                self.properties[i].detectors[j].lastTimestamp = lastTimestamp
                                self.latestTimestampDict[deviceID] = lastTimestamp
                                
                                self.properties[i].detectors[j].threat = overallStatus
                                self.properties[i].threat = overallStatus
                                self.properties[i].propertyDescription = propertyStatus
                                
                            }
                        }
                        
//                        if !flag {
//                            print("removing unneeded detecto")
//                            self.properties[i].detectors.remove(at: j)
//                        }
                    }
//                    print("Property after: \(self.properties[i])")
//                    print("Timestamp map: \(self.latestTimestampDict)")
                    
                    for new_device in devices {
                        var found = false
                        for j in 0..<self.properties[i].detectors.count {
                            if new_device["device_id"] as! String == self.properties[i].detectors[j].id {
                                found = true
                                break
                            }
                        }
                        
                        if !found {
                            let deviceID = new_device["device_id"] as! String
                            
                            if (self.deletedDetectors.contains(deviceID)) {
                                continue
                            } else {
                                print("added fresh detector, \(deviceID), \(self.deletedDetectors)")
                            }
                            
                            let deviceName = new_device["device_name"] as! String
                            let deviceMeasurements = new_device["measurements"] as! [String: Any]
                            let propertyAddress = new_device["property_address"] as! String
                            let latitude = new_device["latitude"] as! Double
                            let longitude = new_device["longitude"] as! Double
                            
                            var deviceBattery = 0.0
                            var fireRatingNumber = 0
                            var fireRating = "0"
                            var temperature = "0"
                            var humidity = "0"
                            var thermalStatus = Threat.Green
                            var spectralStatus = Threat.Green
                            var smokeStatus = Threat.Green
                            var overallStatus = Threat.Green
                            var lastTimestamp = Date()
                            
                            
                            if let batteryString = deviceMeasurements["battery"] as? String {
                                deviceBattery = Double(batteryString)!
                            }
                            if let fireRatingString = deviceMeasurements["risk_probability"] as? String {
                                fireRatingNumber = Int(Double(fireRatingString)!)
                                fireRating = String(fireRatingNumber)
                            }
                            if let temperatureString = deviceMeasurements["temperature"] as? String {
                                let tmp = Int(Double(temperatureString)!)
                                temperature = String(tmp)
                            }
                            
                            if let humidityString = deviceMeasurements["humidity"] as? String {
                                let tmp = Int(Double(humidityString)!)
                                humidity = String(tmp)
                            }
                            
                            if let thermalStatusString = deviceMeasurements["thermal_status"] as? String {
                                let tmp = String(thermalStatusString)
                                if tmp == "YELLOW" {
                                    thermalStatus = Threat.Yellow
                                } else if tmp == "RED" {
                                    thermalStatus = Threat.Red
                                }
                            }
                            
                            if let spectralStatusString = deviceMeasurements["spectral_status"] as? String {
                                let tmp = String(spectralStatusString)
                                if tmp == "YELLOW" {
                                    spectralStatus = Threat.Yellow
                                } else if tmp == "RED" {
                                    spectralStatus = Threat.Red
                                }
                            }
                            
                            if let smokeStatusString = deviceMeasurements["smoke_status"] as? String {
                                let tmp = String(smokeStatusString)
                                if tmp == "YELLOW" {
                                    smokeStatus = Threat.Yellow
                                } else if tmp == "RED" {
                                    smokeStatus = Threat.Red
                                }
                            }
                            
                            if let timeString = deviceMeasurements["time"] as? String {
                                let timestamp = String(timeString)

                                let formatter = DateFormatter()
                                formatter.timeZone = TimeZone(abbreviation: "UTC")

                                // Set the format to match your timestamp
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSSSS"

                                if let date = formatter.date(from: timestamp) {
                                    lastTimestamp = date
//                                    // print("Converted timestamp from \(timestamp) to \(lastTimestamp)")
                                    // Now you can use this 'date' object as needed in your app
                                } else {
                                    // print("Failed to parse date")
                                }

                            }
                            
                            var redFlag = false
                            var yellowFlag = false
                            if let overallStatusString = deviceMeasurements["overall_status"] as? String {
                                let tmp = String(overallStatusString)
//                                // print("[OverallStatusString] \(tmp)")
                                if tmp == "YELLOW" {
                                    overallStatus = Threat.Yellow
                                    propertyStatus = "Warning"
                                    yellowFlag = true
                                } else if tmp == "RED" {
                                    overallStatus = Threat.Red
                                    propertyStatus = "Red alert"
                                    redFlag = true
                                }
                            }
                            
                            var detector = Detector(id: deviceID, deviceName: deviceName, deviceBattery: deviceBattery)
                            detector.measurements["fire_rating"] = fireRating
                            detector.measurements["temperature"] = temperature
                            detector.measurements["humidity"] = humidity
                            detector.spectralStatus = spectralStatus
                            detector.smokeStatus = smokeStatus
                            detector.thermalStatus = thermalStatus
                            detector.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                            detector.sensorIdx = self.properties[i].detectors.count + 1
                            detector.deviceBattery = deviceBattery
//                            detector.lastTimestamp = lastTimestamp
                            self.latestTimestampDict[deviceID] = lastTimestamp
                            self.properties[i].threat = overallStatus
                            self.properties[i].propertyDescription = propertyStatus
                            self.properties[i].detectors.append(detector)
                            
                            if redFlag {
                                redAlert = AlertModel(property: self.properties[i], detector: self.properties[i].detectors.last!, threat: Threat.Red)
                            }
                            if yellowFlag {
                                yellowAlert = AlertModel(property: self.properties[i], detector: self.properties[i].detectors.last!, threat: Threat.Yellow)
                            }
                        }
                    }
                    
//                    var x = 0
//                    for alert in self.alerts {
//                        if (redAlert != nil || yellowAlert != nil) && alert.property.id == self.properties[i].id && alert.detector.measurements["fire_rating"]! != redAlert?.detector.measurements["fire_rating"]! {
//                            // print("removing alert1, old \(alert.detector.measurements["fire_rating"]!) new \(redAlert?.detector.measurements["fire_rating"]!) also \(redAlert)")
//                            self.alerts.remove(at: x)
//                            break
//                        }
//                        
//                        x += 1
//                    }
                    
//                    print("UPDATED PROPERTIES: \(new_property)")
//                    print("ALERTS: \(self.alerts)")
                    if yellowAlert != nil {
//                         print("YELLOW FLAG TRUE")
                        alertsAdded = true
                    }
                    if redAlert != nil {
//                         print("RED FLAG TRUE")
                        alertsAdded = true
                    }
                    
                    // Show red alert, if none then show yellow alert
                    if redAlert != nil {
//                        // print("[ShowRedAlert] \(redAlert?.threat)")
                        redAlert!.property = self.properties[i]
                        
                        var flag = true
                        for (idx, alert) in self.alerts.enumerated() {
                            let alert_prop_id = alert.property.id
                            if redAlert!.property.id == alert_prop_id {
                                flag = false
                                
                                if redAlert!.threat != alert.threat {
                                    self.alerts.remove(at: idx)
                                    self.alerts.append(redAlert!);
                                }
                                
                                break
                            }
                        }
                        
                        if flag {
                            self.alerts.append(redAlert!)
                        }
                    } else if yellowAlert != nil {
                        yellowAlert!.property = self.properties[i]
                        
                        var flag = true
                        for (idx, alert) in self.alerts.enumerated() {
                            let alert_prop_id = alert.property.id
                            if yellowAlert!.property.id == alert_prop_id {
                                flag = false
                                
                                if yellowAlert!.threat != alert.threat {
                                    self.alerts.remove(at: idx)
                                    self.alerts.append(yellowAlert!);
                                }
                                
                                break
                            }
                        }
                        
                        if flag {
                            self.alerts.append(yellowAlert!)
                        }
                    }
                    
                    self.properties[i].loadingData = false
                }
                
                redAlert = nil
                yellowAlert = nil
            }
        }
        
        for i in 0..<self.properties.count {
            var flag = false
            for (id, new_property) in properties {
                if (i < self.properties.count && id == self.properties[i].id) {
                    flag = true
                    break
                }
            }
            if !flag {
                self.properties.remove(at: i)
            }
        }
            
        
        if !alertsAdded {
            self.alerts = []
        }
    }
    
    func uploadNewDetectors() {
//        SessionManager.shared.properties[selectedPropertyIndex].loadingData = true
        self.newProperty?.loadingData = true
        for newDetector in self.newProperty!.detectors {
            self.registerDevice(property: self.newProperty!, detector: newDetector)
        }
    }
    
    func deleteProperty() {
        print("Deleting properties")
        
        var property_id = self.properties[self.selectedPropertyIndex].id
        var user_id = AuthenticationManager.shared.authUser.userId
        
        let req = SocketRequest(route: "deleteProperty",
                                data: [
                                    "property_id": property_id,
                                    "user_id": user_id
                                ],
                                completion: { data in
            print("DeleteProperty: \(data)")
        })
        
        // Send request through socket
        WebSocketManager.shared.sendData(socketRequest: req)
        
        self.deletedProperties.insert(property_id)
        self.properties.remove(at: self.selectedPropertyIndex)
        self.selectedPropertyIndex = min(0, self.properties.count - 1)
    }
    
    func deleteDetector() {
//        print("Deleting detector")
        
        var property_id = self.properties[self.selectedPropertyIndex].id
        var device_id = self.properties[self.selectedPropertyIndex].detectors[self.selectedDetectorIndex].id
        var user_id = AuthenticationManager.shared.authUser.userId
        
        DispatchQueue.main.async {
            self.deletedDetectors.insert(device_id)
            print("deleting detector: \(device_id)")
            self.selectedDetectorIndex -= 1
            self.properties[self.selectedPropertyIndex].detectors.remove(at: self.selectedDetectorIndex + 1)
        }
        
        let req = SocketRequest(route: "deleteDevice",
                                data: [
                                    "property_id": property_id,
                                    "device_id": device_id,
                                ],
                                completion: { data in
            print("DeleteDetector: \(data)")
        })
        
        print("Deleting detector", req)
        
        // Send request through socket
        WebSocketManager.shared.sendData(socketRequest: req)
    }
    
    func registerDevice(property: Property, detector: Detector) {
        // print("Registering new device")
        
        var property = property
        var detector = detector
        
//        // print("Got new property id: \(self.newProperty!.id) from \(self)")
        
        let req = SocketRequest(route: "registerDeviceToProperty",
                                data: [
                                    "property_id": property.id,
                                    "device_id": detector.id,
                                    "property_name": property.propertyName,
                                    "device_name": detector.deviceName,
                                    "property_image": property.propertyImage,
                                    "property_address": property.propertyAddress,
                                    "latitude": detector.coordinate!.latitude,
                                    "longitude": detector.coordinate!.longitude
                                ],
                                completion: { data in
            // print("[RegisterDevice] Received data: \(data)")
                        
//            guard let result = data["result"] as? [String: Any] else {
//                // print("[UploadNewProperty] Couldn't extract result")
//                return
//            }
//
//            guard let property_id = result["property_id"] as? String else {
//                // print("[UploadNewProperty] Failed to create property in backend")
//                return
//            }
            
            detector.sensorIdx = property.detectors.count
//            self.properties[self.properties.count - 1].detectors.append(detector)
//            self.firstTimeLoaded = false
            self.loadUserProperties()
        })
        
        // Send request through socket
        WebSocketManager.shared.sendData(socketRequest: req)
    }
    
    func parseProperty(id: String, property: [String: Any]) {
        // print("[SessionManager] Parsing property with id: \(id)")
        
        guard let devices = property["devices"] as? [[String: Any]] else {
            // print("[ParseProperty] Couldn't extract devices")
            self.unparsedProperties -= 1
            return
        }
        
        guard let name = property["name"] as? String else {
            // print("[ParseProperty] Couldn't extract property name")
            self.unparsedProperties -= 1
            return
        }
        
        guard let address = property["property_address"] as? String else {
            // print("[ParseProperty] Couldn't extract property address")
            self.unparsedProperties -= 1
            return
        }
        
        guard let image = property["property_image"] as? String else {
            // print("[ParseProperty] Couldn't extract property image")
            self.unparsedProperties -= 1
            return
        }

        var geocoder = CLGeocoder()
        var lat = 0.0
        var lon = 0.0
        
        geocoder.geocodeAddressString(address) {
            placemarks, error in
            let placemark = placemarks?.first
            lat = (placemark?.location?.coordinate.latitude)!
            lon = (placemark?.location?.coordinate.longitude)!
            // print("Lat: \(lat), Lon: \(lon)")
            
            var parsedProperty = Property(id: id, propertyName: name, propertyAddress: address, propertyImage: image, coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            var sensorIdx = 0
            var redAlert: AlertModel? = nil
            var yellowAlert: AlertModel? = nil
            var propertyStatus = "All sensors are normal"
            
            for device in devices {
                sensorIdx += 1
                
                // print("parsing device: \(device)")
                
                let deviceID = device["device_id"] as! String
                let deviceName = device["device_name"] as! String
                let deviceMeasurements = device["measurements"] as! [String: Any]
                let propertyAddress = device["property_address"] as! String
                let latitude = device["latitude"] as! Double
                let longitude = device["longitude"] as! Double
                
                var deviceBattery = 0.0
                var fireRatingNumber = 0
                var fireRating = "0"
                var temperature = "0"
                var humidity = "0"
                var thermalStatus = Threat.Green
                var spectralStatus = Threat.Green
                var smokeStatus = Threat.Green
                var overallStatus = Threat.Green
                var lastTimestamp = Date()
                
                if let batteryString = deviceMeasurements["battery"] as? String {
                    deviceBattery = Double(batteryString)!
                }
                if let fireRatingString = deviceMeasurements["risk_probability"] as? String {
                    fireRatingNumber = Int(Double(fireRatingString)!)
                    fireRating = String(fireRatingNumber)
                }
                if let temperatureString = deviceMeasurements["temperature"] as? String {
                    let tmp = Int(Double(temperatureString)!)
                    temperature = String(tmp)
                }
                
                if let humidityString = deviceMeasurements["humidity"] as? String {
                    let tmp = Int(Double(humidityString)!)
                    humidity = String(tmp)
                }
                
                if let thermalStatusString = deviceMeasurements["thermal_status"] as? String {
                    let tmp = String(thermalStatusString)
                    if tmp == "YELLOW" {
                        thermalStatus = Threat.Yellow
                    } else if tmp == "RED" {
                        thermalStatus = Threat.Red
                    }
                }
                
                if let spectralStatusString = deviceMeasurements["spectral_status"] as? String {
                    let tmp = String(spectralStatusString)
                    if tmp == "YELLOW" {
                        spectralStatus = Threat.Yellow
                    } else if tmp == "RED" {
                        spectralStatus = Threat.Red
                    }
                }
                
                if let smokeStatusString = deviceMeasurements["smoke_status"] as? String {
                    let tmp = String(smokeStatusString)
                    if tmp == "YELLOW" {
                        smokeStatus = Threat.Yellow
                    } else if tmp == "RED" {
                        smokeStatus = Threat.Red
                    }
                }
                
                if let timeString = deviceMeasurements["time"] as? String {
                    let timestamp = String(timeString)

                    let formatter = DateFormatter()
                    formatter.timeZone = TimeZone(abbreviation: "UTC")

                    // Set the format to match your timestamp
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSSSS"

                    if let date = formatter.date(from: timestamp) {
                        lastTimestamp = date
                        // print(date)
                        // Now you can use this 'date' object as needed in your app
                    } else {
                        // print("Failed to parse date")
                    }

                }
                
                var redFlag = false
                var yellowFlag = false
                if let overallStatusString = deviceMeasurements["overall_status"] as? String {
                    let tmp = String(overallStatusString)
                    if tmp == "YELLOW" {
                        overallStatus = Threat.Yellow
                        propertyStatus = "Warning"
                        yellowFlag = true
                    } else if tmp == "RED" {
                        overallStatus = Threat.Red
                        propertyStatus = "Red alert"
                        redFlag = true
                    }
                }
                parsedProperty.propertyDescription = propertyStatus
                
                var detector = Detector(id: deviceID, deviceName: deviceName, deviceBattery: deviceBattery)
                detector.measurements["fire_rating"] = fireRating
                detector.measurements["temperature"] = temperature
                detector.measurements["humidity"] = humidity
                detector.spectralStatus = spectralStatus
                detector.smokeStatus = smokeStatus
                detector.thermalStatus = thermalStatus
                detector.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                detector.sensorIdx = sensorIdx
                detector.deviceBattery = deviceBattery
//                detector.lastTimestamp = lastTimestamp
                self.latestTimestampDict[deviceID] = lastTimestamp
                
//                // Check threat
//                if fireRatingNumber >= 80 {
//                    detector.threat = Threat.Red
//                    parsedProperty.threat = Threat.Red
//                    
//                    // Set red alert
//                    redAlert = AlertModel(property: parsedProperty, detector: detector, threat: Threat.Red)
//                } else if fireRatingNumber >= 60 {
//                    detector.threat = Threat.Yellow
////                    parsedProperty.threat = Threat.Yellow
//                    
//                    // Set yellow alert
//                    yellowAlert = AlertModel(property: parsedProperty, detector: detector, threat: Threat.Yellow)
//                }
                
                detector.threat = overallStatus
                
                if redFlag {
                    redAlert = AlertModel(property: parsedProperty, detector: detector, threat: Threat.Red)
                }
                if yellowFlag {
                    yellowAlert = AlertModel(property: parsedProperty, detector: detector, threat: Threat.Yellow)
                }
                
                parsedProperty.detectors.append(detector)
                // print("Added detector \(detector.id) \(parsedProperty)")
            }
            
            // Show red alert, if none then show yellow alert
            if redAlert != nil {
                redAlert!.property = parsedProperty
                self.alerts.append(redAlert!);
            } else if yellowAlert != nil {
                yellowAlert!.property = parsedProperty
                self.alerts.append(yellowAlert!);
            }
            
//            self.checkRedAlert(property: parsedProperty)
            self.properties.append(parsedProperty)
            // print("Finisher parsing \(id) \(self.properties)")
            self.unparsedProperties -= 1
        }
    }
    
    func checkRedAlert(property: Property) {
        
//        for detector in property.detectors {
//            guard var fireRatingString = detector.measurements["fire_rating"] as? String else {
//                // print("[RedAlertCheck] Couldn't extract fire rating from \(detector)")
//                return
//            }
//            let fireRating = Int(fireRatingString)!
//
//            // print("[RedAlertCheck] Got fire rating: \(fireRating)")
//
//            if fireRating >= 80 {
//                // print("[RedAlertCheck] Created red alert: \(self.redAlerts)")
//                self.redAlerts.append(RedAlertModel(property: property, detector: detector))
//            }
//        }
    }
    
    func addNewDetector(detector: Detector) {
        for i in 0..<self.newProperty!.detectors.count {
            self.newProperty!.detectors[i].selected = false
        }
        
//        self.checkRedAlert(property: &self.newProperty!, detector: &detector)
        self.newProperty!.detectors.append(detector)
    }
    
    func deleteNewDetector(detector: Detector) {
        for i in 0..<self.newProperty!.detectors.count {
            if self.newProperty!.detectors[i].id == detector.id {
                self.newProperty!.detectors.remove(at: i)
                
                return
            }
        }
    }
    
    func setDetectorCoordinate(detector: Detector, coordinate: CLLocationCoordinate2D) {
        if self.newProperty == nil {
            return            
        }
        
        for i in 0..<self.newProperty!.detectors.count {
            if self.newProperty!.detectors[i].id == detector.id {
                self.newProperty!.detectors[i].coordinate = coordinate
                
                return
            }
        }
    }
}
