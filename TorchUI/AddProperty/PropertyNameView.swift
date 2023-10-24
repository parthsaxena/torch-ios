//
//  PropertyNameView.swift
//  Pods
//
//  Created by Parth Saxena on 7/11/23.
//

import SwiftUI

struct PropertyNameView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @Binding var state: OnboardingState
    @Binding var propertyName: String
    
    // place holder text color
    @State var fieldTextColor: Color = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
    
    // disabled button color
    @State var nextButtonColor: Color = Color(red: 0.78, green: 0.81, blue: 0.82)
    @State var nextButtonEnabled: Bool = false

    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.propertyName
        }, set: {
            self.propertyName = $0
            
            // update textfield color
            if $0 != "Enter property name" {
                fieldTextColor = CustomColors.TorchGreen
            } else {
                fieldTextColor = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
            }
            
            if !self.propertyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // enabled button color
                nextButtonEnabled = true
                nextButtonColor = Color(red: 0.18, green: 0.21, blue: 0.22)
            } else {
                // disabled button color
                nextButtonEnabled = false
                nextButtonColor = Color(red: 0.78, green: 0.81, blue: 0.82)
            }
        })
        
        VStack {
            // Progress bar
            HStack(spacing: 4.0) {
                let progressItemWidth = (UIScreen.main.bounds.width - 40) / 4
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(self.state.rawValue >= OnboardingState.propertyName.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(self.state.rawValue >= OnboardingState.propertyAddress.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(self.state.rawValue >= OnboardingState.propertyPhoto.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(self.state.rawValue >= OnboardingState.promptInstallation.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
            }
            .padding(.top, 20)
            
            // Heading
            ZStack {                
                
                HStack {
                    Spacer()
                    
                    Text("Add new property")
                        .font(Font.custom("Manrope-SemiBold", size: 18.0))
                        .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0))
                            .font(Font.system(size: 18.0))
                    }
                    .padding(.trailing, 20.0)
                }
            }
            .padding(.top, 20)
            
            Spacer()
            
            HStack {
                Spacer()
                VStack {
                    TextField("Enter property name", text: binding)
                        .font(Font.custom("Manrope-SemiBold", size: 30))
                        .minimumScaleFactor(0.7)
                        .foregroundColor(fieldTextColor)
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .focused($focusedField, equals: .field)
                        .onAppear {
//                            self.focusedField = .field
                        }
                    
                    Text("Property name")
                        .font(Font.custom("Manrope-Medium", size: 16.0))
                        .foregroundColor(Color(red: 0.45, green: 0.53, blue: 0.55))
                        .padding(.top, 5.0)
                }
                Spacer()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    
                    SessionManager.shared.newProperty = Property(id: "", propertyName: binding.wrappedValue, propertyAddress: "", propertyImage: "")
                    self.state = .propertyAddress
                }) {
                    Text("Next")
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
                
//                Button("Next") {
//                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                    impactMed.impactOccurred()
//
//                    SessionManager.shared.newProperty = Property(id: "", propertyName: binding.wrappedValue, propertyAddress: "", propertyImage: "")
//                    self.state = .propertyAddress
//                }
//                    .disabled(!nextButtonEnabled)
//                    .font(.custom("Manrope-SemiBold", size: 16))
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 60)
//                    .foregroundColor(.white)
//                    .background(
//                        RoundedRectangle(cornerRadius: 100)
//                            .foregroundColor(self.nextButtonColor)
//                    )
//                    .padding(.horizontal, 16)
//                    .padding(.bottom, 20)
                Spacer()
            }
            .padding(.top, 60)
        }
    }
}

//struct PropertyNameView_Previews: PreviewProvider {
//    static var previews: some View {
//        PropertyNameView(state: <#Binding<OnboardingState>#>, propertyName: <#Binding<String>#>)
//    }
//}
