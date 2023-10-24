//
//  AddPropertySheetView.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/9/23.
//

import SwiftUI

enum FocusField: Hashable {
    case field
}

enum OnboardingState: Int {
    case propertyName
    case propertyAddress
    case propertyPhoto
    case connectToHub
    case promptInstallation
    case placeSensors
}

struct AddPropertySheetView: View {
    @Environment(\.dismiss) var dismiss
    
    @State var state: OnboardingState = .propertyName
    @State var propertyName: String = ""
    @State var propertyAddress: String = ""
//    @State var propertyName: String = "momm"
//    @State var propertyAddress: String = "2237 Kamp Court, Pleasanton, CA 94588"
    
    var body: some View {
        if state == .propertyName {            
            PropertyNameView(state: $state, propertyName: $propertyName)
        } else if state == .propertyAddress {
            PropertyAddressView(vm: PropertyAddressViewModel(), state: $state, propertyName: propertyName, propertyAddress: $propertyAddress)
        } else if state == .propertyPhoto {
            PropertyPhotoView(state: $state, propertyName: propertyName, propertyAddress: propertyAddress)
        } else if state == .connectToHub {
            
        } else if state == .promptInstallation {
            PromptInstallationView(state: $state, propertyName: propertyName, propertyAddress: propertyAddress)
        } else if state == .placeSensors {
            PlaceSensorView()
        }
    }
}

struct AddPropertyBackButton: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @Binding var state: OnboardingState
    
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
                
                UIApplication.shared.endEditing()
                
                if self.state == OnboardingState.propertyName {
                    dismiss()
                } else {
                    self.state = OnboardingState(rawValue: self.state.rawValue - 1)!
                }
            } label: {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 60.0, height: 60.0)
            }
        }
        .shadow(color: CustomColors.LightGray.opacity(0.3), radius: 5.0)
    }
}

struct ContentView: View {
    @State private var showingSheet = true
    

    var body: some View {
        Button("Show Sheet") {
            showingSheet.toggle()
        }
        .sheet(isPresented: $showingSheet) {
        AddPropertySheetView(propertyName: "asd")
                .presentationCornerRadius(100)
        }
    }
}

struct AddPropertySheetView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
