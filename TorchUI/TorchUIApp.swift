//
//  TorchUIApp.swift
//  TorchUI
//
//  Created by Parth Saxena on 6/28/23.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin

struct CustomColors {
//    @Environment(\.colorScheme) var colorScheme
    
    static let TorchRed = Color(red: 0.94, green: 0.27, blue: 0.22)
    static let TorchGreen = Color(red: 0.27, green: 0.32, blue: 0.33)
//    static let TorchGreen = colorScheme == .dark ? Color.white : Color(red: 0.27, green: 0.32, blue: 0.33)
    static let LightGray = Color(red: 0.56, green: 0.63, blue: 0.64)
    static let NormalSensorGray = Color(red: 0.95, green: 0.95, blue: 0.95)
    static let DetectorDetailsShadow = Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.08)
    static let GoodGreen = Color(red: 0.09, green: 0.7, blue: 0.39)
    static let WarningYellow = Color(red: 0.97, green: 0.56, blue: 0.03)
    
    static let DisabledButtonColor: Color = Color(red: 0.78, green: 0.81, blue: 0.82)
    static let EnabledButtonColor: Color = Color(red: 0.18, green: 0.21, blue: 0.22)
    
    static let DarkModeBackground = Color(red: 0.17, green: 0.18, blue: 0.2)
    static let DarkModeMainTestColor = Color(red: 1, green: 0.36, blue: 0.14)
    static let DarkModeOverlayBackground = Color(red: 55/255, green: 58/255, blue: 61/255)
//    rgba(55, 58, 61, 1)
}

@main
struct TorchUIApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @ObservedObject var sessionManager = SessionManager.shared
    @ObservedObject var authenticationManager = AuthenticationManager.shared
    
    var body: some Scene {
        WindowGroup {
            
//            AccountView()
            
                switch authenticationManager.authState {
                    case .login:
                        AccountView()
                    
                    case .authenticated:
//                        switch sessionManager.appState {
//
//                            case .properties:
//                                let x = // print("Pooper \(sessionManager.appState)")
//                                PropertiesView()
//
//
//                            case .viewProperty:
//                                let x = // print("Dooper \(sessionManager.appState)")
//                                MainMapView()
//                        }
                        AccountView()
                        .animation(.none)
                    
                    default:
                        AccountView()
                }
        }
    }
    
    init() {
        do {
//            UIFont.familyNames.forEach({ familyName in
//                let fontNames = UIFont.fontNames(forFamilyName: familyName)
//                // print(familyName, fontNames)
//            })
            
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            WebSocketManager.shared.connect()        
            
            Task {
                await AuthenticationManager.shared.fetchCurrentAuthSession()
            }
            // print("Amplify configured with Auth plugin")
        } catch {
            // print("Failed to initialize Amplify with error: \(error)")
        }
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

extension String {
    subscript (index: Int) -> Character {
        let charIndex = self.index(self.startIndex, offsetBy: index)
        return self[charIndex]
    }

    subscript (range: Range<Int>) -> Substring {
        let startIndex = self.index(self.startIndex, offsetBy: range.startIndex)
        let stopIndex = self.index(self.startIndex, offsetBy: range.startIndex + range.count)
        return self[startIndex..<stopIndex]
    }

}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
