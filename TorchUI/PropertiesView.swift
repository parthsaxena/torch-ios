//
//  PropertiesView.swift
//  TorchUI
//
//  Created by Parth Saxena on 6/26/23.
//

import SwiftUI
import SwiftUI_Shimmer

struct PropertiesView: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSheet = false
//    @State private var showSplashScreen = true
    
    let tabs: [TabBarItemData] = [
        TabBarItemData(image: "home", selectedImage: "home", size: 24),
        TabBarItemData(image: "search", selectedImage: "web-icon", size: 24),
        TabBarItemData(image: "main-nav", selectedImage: "roster-icon", size: 54),
        TabBarItemData(image: "notif", selectedImage: "match-icon", size: 24),
        TabBarItemData(image: "settings", selectedImage: "match-icon", size: 24)]
//    let properties: [Property] = [
//        Property(id: 0, propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: "Property"),
//        Property(id: 1, propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: "Property"),
//        Property(id: 2, propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: "Property"),
//        Property(id: 3, propertyName: "House in Napa", propertyAddress: "2237 Kamp Court", propertyImage: "Property"),
//    ]        
    
    private let width = UIScreen.main.bounds.width
    private let height = UIScreen.main.bounds.height
    
    @State var selectedIndex = 0
    
    var body: some View {
        ZStack {
            // List alerts / properties
            if SessionManager.shared.showSplashScreen {
                LoadingSplashScreen()
                    .onAppear(perform: hideSplashScreen)
            } else if !SessionManager.shared.propertiesLoaded || SessionManager.shared.unparsedProperties > 0 {
//                let x = // print("shimmer \(SessionManager.shared.propertiesLoaded) \(SessionManager.shared.unparsedProperties > 0)")
                LoadingPropertiesView(showingSheet: $showingSheet)
                VStack {
                    HeadingView()
                        .frame(alignment: .top)
                    
                    Spacer()

                    TabBarView(tabBarItems: tabs, selectedIndex: $selectedIndex)
                        .frame(alignment: .bottom)
                }
            } else if SessionManager.shared.properties.count > 0 {
                MainPropertiesView(showingSheet: $showingSheet)
                VStack {
                    HeadingView()
                        .frame(alignment: .top)
                    
                    Spacer()

                    TabBarView(tabBarItems: tabs, selectedIndex: $selectedIndex)
                        .frame(alignment: .bottom)
                }
            } else if SessionManager.shared.propertiesLoaded && SessionManager.shared.unparsedProperties == 0 {
                NoPropertiesView(showingSheet: $showingSheet)
                VStack {
                    HeadingView()
                        .frame(alignment: .top)
                    
                    Spacer()

                    TabBarView(tabBarItems: tabs, selectedIndex: $selectedIndex)
                        .frame(alignment: .bottom)
                }
            }
        }
        .background(colorScheme == .dark ? CustomColors.DarkModeBackground : Color.white)
        .sheet(isPresented: $showingSheet) {
            AddPropertySheetView()
                .presentationCornerRadius(25)
        }
    }
    
    func hideSplashScreen() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            // print("OVER")
            SessionManager.shared.showSplashScreen = false
        }
    }
}

struct AlertView: View {
    @Environment(\.colorScheme) var colorScheme
    var model: AlertModel
    
    var body: some View {
        VStack {
            var threatColorText = model.threat == Threat.Red ? "Red Alert" : "Warning"
            var textColor = model.threat == Threat.Red ? CustomColors.TorchRed : CustomColors.WarningYellow
            
            HStack(spacing: 4.0) {
                Spacer()
                Text("\(threatColorText):")
                    .font(Font.custom("Manrope-Bold", size: 20))
                    .foregroundColor(colorScheme == .dark ? Color.white : textColor)
                Text(model.property.propertyName)
                    .font(Font.custom("Manrope-Light", size: 20))
                    .foregroundColor(colorScheme == .dark ? Color.white : textColor)
                Spacer()
            }
            .padding(.top, 70)
            
            Text("There is a \(model.detector.measurements["fire_rating"]!)% chance of fire on this property. \nCall the fire department now.")
                .font(Font.custom("Manrope-Medium", size: 14))
                .frame(height: 40)
                .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : CustomColors.LightGray)
                .multilineTextAlignment(.center)
            
            HStack {
                Spacer()
                
                Image("LocationMarker")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : CustomColors.LightGray)
                    .frame(width: 16.0, height: 16.0)
                
                Text(model.property.propertyAddress)
                    .font(Font.custom("Manrope-Medium", size: 12.0))
                    .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.6) : CustomColors.LightGray)
                
                Spacer()
            }
            
            HStack {
                Spacer()
               
                Button("View sensor data") {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    SessionManager.shared.selectedProperty = model.property
                    SessionManager.shared.appState = .viewProperty
                    // print("Property \(model.property.propertyName) tapped, \(SessionManager.shared.appState)")
                }
                .font(.custom("Manrope-SemiBold", size: 16))
                .frame(maxWidth: 229)
                .frame(maxHeight: 28)
                .frame(height: 56)
                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .foregroundColor(colorScheme == .dark ? Color.white.opacity(0.3) : Color(red: 0.95, green: 0.95, blue: 0.95))
                )
                
                
                Circle()
                .fill(colorScheme == .dark ? LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color.white, location: 0.00),
                        Gradient.Stop(color: Color.white, location: 1.00),
                    ], startPoint: UnitPoint(x: 0.25, y: 0.08), endPoint: UnitPoint(x: 0.7, y: 0.97)
                ) :
                    LinearGradient(
                        stops: [
                        Gradient.Stop(color: Color(red: 1, green: 0.35, blue: 0.14), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.91, green: 0.21, blue: 0.04), location: 0.56),
                        Gradient.Stop(color: Color(red: 0.87, green: 0.15, blue: 0), location: 1.00),
                        ], startPoint: UnitPoint(x: 0.25, y: 0.08), endPoint: UnitPoint(x: 0.7, y: 0.97)
                    )
                )
                .frame(width: 56, height: 56)
                .overlay(
                    Image("PhoneIcon")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(colorScheme == .dark ? CustomColors.TorchRed : Color.white)
                        .frame(width: 20, height: 20)
                )
                
                Spacer()
            }
            .padding(.bottom, 15)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .frame(height: 280)
        .background(
            ZStack {
                Image("ThreatAlertBackground")
                    .resizable()
                
                if colorScheme == .dark {
                    
                    Rectangle()
                        .fill(Color.black.opacity(0.85))
                        .ignoresSafeArea()
                    
                    let orangeColor = Color(red: 1, green: 0.35, blue: 0.14)
                    LinearGradient(gradient: Gradient(colors: [.clear, .clear, orangeColor.opacity(0.3), orangeColor.opacity(0.5),orangeColor.opacity(0.7)]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                        .opacity(1)
                } else {
                    LinearGradient(gradient: Gradient(colors: [.clear, .clear, Color.white, Color.white, Color.white]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                        .opacity(1)
                }
                
                VStack {
                    HStack {
                        Spacer()
                        Image("TorchIndicator")
                            .resizable()
                            .frame(width: 100, height: 109)
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        )
        .cornerRadius(24)
        .shadow(color: Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.08), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 16)
//        .padding(.top, 100)
    }
}

struct MainPropertiesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showingSheet: Bool
    
    @ObservedObject var sessionManager = SessionManager.shared
    
    var body: some View {
        VStack {            
            ScrollView {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 90)
                    .contentShape(Rectangle())
                
                VStack {
                    // Alerts
                    ForEach(SessionManager.shared.alerts) { alert in
                        AlertView(model: alert)
                    }
                    
                    // All properties
                    VStack {
                        // Heading "All properties"
                        HStack {
                            Text("All properties")
                                .font(Font.custom("Manrope-SemiBold", size: 18))
                                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                                .multilineTextAlignment(.center)
                            
                            Text("\(SessionManager.shared.properties.count)")
                                .font(Font.custom("Manrope-SemiBold", size: 16))
                                .foregroundColor(CustomColors.LightGray)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                            
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                self.showingSheet.toggle()
                            } label: {
                                HStack {
                                    Text("Add")
                                        .font(Font.custom("Manrope-SemiBold", size: 14))
                                        .foregroundColor(CustomColors.LightGray)
                                        .multilineTextAlignment(.center)
                                    
                                    Image(systemName: "plus")
                                        .foregroundColor(CustomColors.LightGray)
                                        .font(Font.system(size: 14.0))
                                }
                            }
                        }
                        
                        VStack {
                            
                            ForEach(Array(sessionManager.properties.enumerated()), id: \.element) { idx, property in
                                PropertyView(property: property)
                                    .equatable()
                                    .onTapGesture {
                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                        impactMed.impactOccurred()
                                        
                                        SessionManager.shared.selectedProperty = property
                                        SessionManager.shared.selectedPropertyIndex = idx
                                        withAnimation {
                                            SessionManager.shared.appState = .viewProperty
                                        }
//                                        SessionManager.shared.appState = .viewProperty
                                        // print("Property \(property.propertyName) tapped, \(SessionManager.shared.appState)")
                                    }                                    
//                                    .shimmering()
                                
                                if idx < SessionManager.shared.properties.count - 1 {
                                    Divider()
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
    //                    .background(.white)
                    .background(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.08), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
                    .contentShape(Rectangle())
            }
        }
    }
}

struct NoPropertiesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showingSheet: Bool
    
    @ObservedObject var sessionManager = SessionManager.shared
    
    var body: some View {
        
        ZStack {
            
            VStack {
//                HStack {
//                    Text("Home")
//                        .font(Font.custom("Manrope-SemiBold", size: 36))
//                        .foregroundColor(colorScheme == .dark ? CustomColors.DarkModeMainTestColor : CustomColors.TorchGreen)
//                        .multilineTextAlignment(.center)
//
//                    Spacer()
//
//                    Image("Avatar")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 48, height: 48)
//                        .clipped()
//                        .cornerRadius(100)
//                        .shadow(color: Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.03), radius: 4, x: 0, y: 8)
//                        .shadow(color: Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.08), radius: 12, x: 0, y: 20)
//                        .onTapGesture {
//                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                            impactMed.impactOccurred()
//
//                            Task {
//                                await AuthenticationManager.shared.signOut()
//                            }
//                        }
//                }
//                .padding(.horizontal, 16)
//                .padding(.top, 20)
                
                Spacer()
                
                VStack {
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Circle()
                                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                                .frame(width: 200, height: 200)
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                self.showingSheet.toggle()
                            } label: {
                                Circle()
                                    .fill(Color.clear)
                                    .frame(width: 200, height: 200)
                            }
                        }
                        .shadow(color: CustomColors.LightGray.opacity(0.3), radius: 5.0)
                        
                        Spacer()
                    }
                    
                    Text("Add your first property")
                        .font(Font.custom(("Manrope-Semibold"), size: 20.0))
                        .foregroundColor(CustomColors.TorchGreen)
                        .padding(.top, 20)
                }
                .padding(.bottom, 40)
                
                Spacer()
            }
            
            if (!sessionManager.propertiesLoaded) {
                LoadingSplashScreen()
            }
        }
    }
}

struct LoadingPropertiesView: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var showingSheet: Bool
    
    @ObservedObject var sessionManager = SessionManager.shared
    
    var body: some View {
        VStack {
            ScrollView {
                Rectangle()
                    .fill(.clear)
                    .frame(height: 90)
                    .contentShape(Rectangle())
                
                VStack {
//                    // Alerts
//                    ForEach(SessionManager.shared.alerts) { alert in
//                        AlertView(model: alert)
//                    }
                    
                    // All properties
                    VStack {
                        // Heading "All properties"
                        HStack {
                            Text("All properties")
                                .font(Font.custom("Manrope-SemiBold", size: 18))
                                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                                .multilineTextAlignment(.center)
                                .redacted(reason: .placeholder)
                                .shimmering()
                            
                            Text("\(SessionManager.shared.properties.count)")
                                .font(Font.custom("Manrope-SemiBold", size: 16))
                                .foregroundColor(CustomColors.LightGray)
                                .multilineTextAlignment(.center)
                                .redacted(reason: .placeholder)
                                .shimmering()
                            
                            Spacer()
                            
                            Button {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                self.showingSheet.toggle()
                            } label: {
                                HStack {
                                    Text("Add")
                                        .font(Font.custom("Manrope-SemiBold", size: 14))
                                        .foregroundColor(CustomColors.LightGray)
                                        .multilineTextAlignment(.center)
                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                    
                                    Image(systemName: "plus")
                                        .foregroundColor(CustomColors.LightGray)
                                        .font(Font.system(size: 14.0))
//                                        .redacted(reason: .placeholder)
                                        .shimmering()
                                }
                            }
                        }
                        
                        VStack {
                            ForEach(Array(sessionManager.loadingProperties.enumerated()), id: \.element) { idx, property in
                                PropertyView(property: property, loading: true)
//                                    .onTapGesture {
//                                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                                        impactMed.impactOccurred()
//
//                                        SessionManager.shared.selectedProperty = property
//                                        SessionManager.shared.appState = .viewProperty
//                                        // print("Property \(property.propertyName) tapped, \(SessionManager.shared.appState)")
//                                    }
//                                    .shimmering()
                                
                                if idx < SessionManager.shared.properties.count - 1 {
                                    Divider()
                                        .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
    //                    .background(.white)
                    .background(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
                    .cornerRadius(24)
                    .shadow(color: Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.08), radius: 12, x: 0, y: 4)
                    .padding(.horizontal, 16)
                    .padding(.top, 10)
                    
                    Spacer()
                }
                
                Rectangle()
                    .fill(.clear)
                    .frame(height: 100)
                    .contentShape(Rectangle())
            }
        }
    }
}

struct PropertiesView_Previews: PreviewProvider {
    static var previews: some View {
        PropertiesView()
    }
}
