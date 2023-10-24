//
//  AccountNameView.swift
//  TorchUI
//
//  Created by Parth Saxena on 8/2/23.
//

import SwiftUI

struct AccountEmailView: View {
    @Environment(\.colorScheme) var colorScheme
        
    @Binding var accountEmail: String
    
    // place holder text color
    @State var fieldTextColor: Color = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
    
    // disabled button color
    @State var nextButtonColor: Color = Color(red: 0.78, green: 0.81, blue: 0.82)
    @State var nextButtonEnabled: Bool = false

    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        let binding = Binding<String>(get: {
            self.accountEmail
        }, set: {
            self.accountEmail = $0
            
            // update textfield color
            if $0 != "Enter your email" {
                fieldTextColor = colorScheme == .dark ? Color.white : CustomColors.TorchGreen
            } else {
                fieldTextColor = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
            }
            
            if !self.accountEmail.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
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
                let progressItemWidth = (UIScreen.main.bounds.width - 50) / 5
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(AuthenticationManager.shared.authState.rawValue >= AuthState.accountName.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(AuthenticationManager.shared.authState.rawValue >= AuthState.accountEmail.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(AuthenticationManager.shared.authState.rawValue >= AuthState.companyName.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(AuthenticationManager.shared.authState.rawValue >= AuthState.accountPassword.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
                
                RoundedRectangle(cornerRadius: 5.0)
                    .frame(width: progressItemWidth, height: 4)
                    .foregroundColor(AuthenticationManager.shared.authState.rawValue >= AuthState.accountVerificationCode.rawValue ? CustomColors.TorchGreen : Color(red: 227/255, green: 231/255, blue: 232/255))
            }
            .padding(.top, 10)
            
            // Heading
            ZStack {
                HStack {
                    AccountBackButton()
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    
                    Text("Create account")
                        .font(Font.custom("Manrope-SemiBold", size: 18.0))
                        .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                    
                    Spacer()
                }
            }
            .padding(.top, 10)
            .padding(.horizontal, 15)
            
            Spacer()
            
            HStack {
                Spacer()
                VStack {
                    TextField("Enter your email", text: binding)
                        .font(Font.custom("Manrope-SemiBold", size: 30))
                        .minimumScaleFactor(0.7)
                        .foregroundColor(fieldTextColor)
                        .multilineTextAlignment(.center)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .field)
                        .onAppear {
                            self.focusedField = .field
                        }
                    
                    Text("What's your email?")
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
                    
                    AuthenticationManager.shared.authState = .companyName
                }) {
                    Text("Next")
                    .font(.custom("Manrope-SemiBold", size: 16))
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .foregroundColor(colorScheme == .dark ? CustomColors.TorchGreen : .white)
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
//                    AuthenticationManager.shared.authState = .companyName
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
        .background(colorScheme == .dark ? CustomColors.DarkModeBackground : Color.white)
    }
}

//struct AccountBackButton: View {
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        ZStack {
//            Circle()
//                .fill(colorScheme == .dark ? CustomColors.DarkModeOverlayBackground : Color.white)
//                .frame(width: 48.0, height: 48.0)
//            Image(systemName: "chevron.backward")
//                .frame(width: 48.0, height: 48.0)
//                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
//            Button {
//                let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                impactMed.impactOccurred()
//
////                showDetectorDetails = false
//            } label: {
//                Circle()
//                    .fill(Color.clear)
//                    .frame(width: 60.0, height: 60.0)
//            }
//        }
//        .shadow(color: CustomColors.LightGray.opacity(0.3), radius: 5.0)
//    }
//}

struct AccountEmailView_Previews: PreviewProvider {
    @State static var accountEmail = ""
    @State static var state = AccountState.accountEmail
    
    static var previews: some View {
        AccountEmailView(accountEmail: $accountEmail)
    }
}
