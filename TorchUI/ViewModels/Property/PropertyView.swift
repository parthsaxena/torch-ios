//
//  PropertyView.swift
//  TorchUI
//
//  Created by Parth Saxena on 6/28/23.
//

import Foundation
import SwiftUI
import SwiftUI_Shimmer

struct PropertyView: View, Equatable {
    static func == (lhs: PropertyView, rhs: PropertyView) -> Bool {
//        // print("equality check")
        
        let lhs_property = lhs.property
        let rhs_property = rhs.property
        
        if (lhs_property.id != rhs_property.id) {
            // print("equality check fail 1")
            return false
        }
        
        if (lhs_property.threat != rhs_property.threat) {
            // print("equality check fail 2")
            return false
        }
        
        if (lhs_property.propertyDescription != rhs_property.propertyDescription) {
            // print("equality check fail 3")
            return false
        }
        
        if (lhs_property.detectors.count != rhs_property.detectors.count) {
            // print("equality check fail 4")
            return false
        }
        
        for lhs_detector in lhs_property.detectors {
            for rhs_detector in rhs_property.detectors {
                if lhs_detector.id == rhs_detector.id {
                    if (lhs_detector.threat != rhs_detector.threat) {
                        // print("equality check fail 5")
                        return false
                    }
                }
            }
        }
        
//        // print("equality check pass")
        
        return true
    }
    
    var colorScheme = ColorScheme.light
    var property: Property
    var loading = false
    
    var body: some View {
        let x = print("Property loading: \(self.property.loadingData)")
        
        HStack {
            if loading {
                Rectangle()
                    .foregroundColor(CustomColors.LightGray)
                    .frame(width: 60, height: 60)
                    .cornerRadius(12)
                    .shimmering()
            } else {
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
            }
            
            Spacer()
                .frame(width: 15)
            
            // Fire yellow image
            let fireImageYellow = UIImage(named: "FireYellow")
            let uiImageYellow = UIImage(cgImage: (fireImageYellow?.cgImage)!, scale: 5.0, orientation: (fireImageYellow?.imageOrientation)!)
            let imageFireYellow = Image(uiImage: uiImageYellow)
            
            // Red yellow image
            let fireImageRed = UIImage(named: "FireRed")
            let uiImageRed = UIImage(cgImage: (fireImageRed?.cgImage)!, scale: 4.2, orientation: (fireImageRed?.imageOrientation)!)
            let imageFireRed = Image(uiImage: uiImageRed)
            
            
            VStack(alignment: .leading, spacing: 2) {
                if loading {
                    Text("Loading")
                    .font(Font.custom("Manrope-SemiBold", size: 16))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.27, green: 0.32, blue: 0.33))
                    .redacted(reason: .placeholder)
                    .shimmering()
                } else if property.threat == Threat.Red {
                    Text("\(property.propertyName)   \(imageFireRed)")
                    .font(Font.custom("Manrope-SemiBold", size: 16))
                    .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.27, green: 0.32, blue: 0.33))
                } else {
                    Text("\(property.propertyName)")
                        .font(Font.custom("Manrope-SemiBold", size: 16))
                        .foregroundColor(colorScheme == .dark ? Color.white : Color(red: 0.27, green: 0.32, blue: 0.33))
                }
                
                if loading {
                    Text("All sensors are normal")
                      .font(Font.custom("Manrope-Medium", size: 14))
                      .foregroundColor(Color(red: 0.56, green: 0.63, blue: 0.64))
                      .frame(maxWidth: .infinity, minHeight: 20, maxHeight: 20, alignment: .topLeading)
                      .redacted(reason: .placeholder)
                      .shimmering()
                } else {
                    if (property.detectors.count > 0) {
                        Text(property.propertyDescription)
                            .font(Font.custom("Manrope-Medium", size: 14))
                            .foregroundColor(Color(red: 0.56, green: 0.63, blue: 0.64))
                            .frame(maxWidth: .infinity, minHeight: 20, maxHeight: 20, alignment: .topLeading)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Spacer()
            
            let sensorSpacing = 4.0
            let sensorSize = 14.0
            
            if !loading {
                if self.property.loadingData {
                    ProgressView()
                } else {
                    VStack(spacing: sensorSpacing) {
                        // row 1
                        HStack(spacing: sensorSpacing) {
                            ForEach(0..<5, id: \.self) { i in
                                if i < property.detectors.count {
                                    if property.detectors[i].threat == Threat.Red {
                                        Circle().fill(CustomColors.TorchRed).frame(width: 14, height: 14)
                                    } else if property.detectors[i].threat == Threat.Yellow {
                                        Circle().fill(CustomColors.WarningYellow).frame(width: 14, height: 14)
                                    } else {
                                        Circle().fill(colorScheme == .dark ? Color(red: 44/255,green: 47/255, blue: 51/255) : CustomColors.NormalSensorGray).frame(width: 14, height: 14)
                                    }
                                } else {
                                    Circle().fill(Color.clear).frame(width: 14, height: 14)
                                }
                            }
                            Spacer()
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        
                        // row 2
                        HStack(spacing: sensorSpacing) {
                            ForEach(5..<10, id: \.self) { i in
                                if i < property.detectors.count {
                                    if property.detectors[i].threat == Threat.Red {
                                        Circle().fill(CustomColors.TorchRed).frame(width: 14, height: 14)
                                    } else if property.detectors[i].threat == Threat.Yellow {
                                        Circle().fill(CustomColors.WarningYellow).frame(width: 14, height: 14)
                                    } else {
                                        Circle().fill(colorScheme == .dark ? Color(red: 44/255,green: 47/255, blue: 51/255) : CustomColors.NormalSensorGray).frame(width: 14, height: 14)
                                    }
                                } else {
                                    Circle().fill(Color.clear).frame(width: 14, height: 14)
                                }
                            }
                            Spacer()
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                        
                        // row 3
                        HStack(spacing: sensorSpacing) {
                            ForEach(10..<15, id: \.self) { i in
                                if i < property.detectors.count {
                                    if property.detectors[i].threat == Threat.Red {
                                        Circle().fill(CustomColors.TorchRed).frame(width: 14, height: 14)
                                    } else if property.detectors[i].threat == Threat.Yellow {
                                        Circle().fill(CustomColors.WarningYellow).frame(width: 14, height: 14)
                                    } else {
                                        Circle().fill(colorScheme == .dark ? Color(red: 44/255,green: 47/255, blue: 51/255) : CustomColors.NormalSensorGray).frame(width: 14, height: 14)
                                    }
                                } else {
                                    Circle().fill(Color.clear).frame(width: 14, height: 14)
                                }
                            }
                            Spacer()
                        }
                        .environment(\.layoutDirection, .rightToLeft)
                    }
                    .frame(maxWidth: sensorSize * 5 + 4 * sensorSpacing)
                    .padding(.trailing, 10)
                }
            }
        }
    }
}

struct SearchResultView: View {
    @State var address: String
    var userEntry: String
    
    private struct HighlightedText: View {
        var text: String
        var highlighted: String

        var body: some View {
            Text(attributedString)
        }
        
        func findLengthOfCommonPrefix(str1: String, str2: String) -> Int {
            for (idx, c) in str1.enumerated() {
                if idx >= str2.count || str1[idx].lowercased() != str2[idx].lowercased() {
                    return idx
                }
            }
            
            return 0
        }

        private var attributedString: AttributedString {
            var attributedString = AttributedString(text)
            let prefixIdx = findLengthOfCommonPrefix(str1: text.lowercased(), str2: highlighted.lowercased())
//            // print("high: \(highlighted) : text: \(text) : idx: \(prefixIdx)")
            let h = highlighted.substring(to: highlighted.firstIndex(of: highlighted[min(prefixIdx, highlighted.count - 1)])!)

            if let range = AttributedString(text.lowercased()).range(of: h.lowercased()) {
                attributedString[range].backgroundColor = Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.1)
            }

            return attributedString
        }
    }
    
    var body: some View {
        HStack {
            Image("LocationMarker")
                .resizable()
                .frame(width: 16, height: 16)
            
//            let addressArray = Array(address)
//            let prefixIdx = findLengthOfCommonPrefix(str1: address, str2: userEntry)
            
            HighlightedText(text: address, highlighted: userEntry)
                .font(Font.custom("Manrope-Medium", fixedSize: 14.0))
            
//            Text(address[0..<prefixIdx])
//                .font(Font.custom("Manrope-Medium", fixedSize: 14.0))
//                .background(Color(red: 0.18, green: 0.21, blue: 0.22))
//
//            +            Text(address[prefixIdx...])
//                .font(Font.custom("Manrope-Medium", fixedSize: 14.0))
            
            Spacer()
        }
//        .padding(.horizontal, 2)
        .padding(.vertical, 8)
    }
}

struct PropertyView_Previews: PreviewProvider {
    static var previews: some View {
        PropertyView(property: SessionManager.shared.selectedProperty!)
    }
}
