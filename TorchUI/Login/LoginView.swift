//
//  AccountNameView.swift
//  TorchUI
//
//  Created by Parth Saxena on 8/2/23.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.colorScheme) var colorScheme
        
    @State var accountEmail: String = ""
    @State var accountPassword: String = ""
    
    // place holder text color
    @State var fieldTextColor: Color = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
    
    // disabled button color
    @State var nextButtonColor: Color = Color(red: 0.78, green: 0.81, blue: 0.82)
    @State var nextButtonEnabled: Bool = false

    @FocusState private var focusedField: FocusField?
    
    var body: some View {
        let emailBinding = Binding<String>(get: {
            self.accountEmail
        }, set: {
            self.accountEmail = $0
            
            // update textfield color
            if $0 != "Enter your email" {
                fieldTextColor = colorScheme == .dark ? Color.white : CustomColors.TorchGreen
            } else {
                fieldTextColor = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
            }
            
            if !self.accountEmail.isEmpty {
                // enabled button color
                nextButtonEnabled = true
                nextButtonColor = Color(red: 0.18, green: 0.21, blue: 0.22)
            } else {
                // disabled button color
                nextButtonEnabled = false
                nextButtonColor = Color(red: 0.78, green: 0.81, blue: 0.82)
            }
        })
        
        let passwordBinding = Binding<String>(get: {
            self.accountPassword
        }, set: {
            self.accountPassword = $0
            
            // update textfield color
            if $0 != "Enter your password" {
                fieldTextColor = colorScheme == .dark ? Color.white : CustomColors.TorchGreen
            } else {
                fieldTextColor = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
            }
            
            if !self.accountPassword.isEmpty {
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
            
            // Heading
            ZStack {
                HStack {
                    AccountBackButton()
                    
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    
                    Text("Log in")
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
                    TextField("Enter your email", text: emailBinding)
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
                    
                    Spacer()
                        .frame(height: 30)
                    
                    SecureField("Enter your password", text: passwordBinding)
                        .font(Font.custom("Manrope-SemiBold", size: 30))
                        .minimumScaleFactor(0.7)
                        .foregroundColor(fieldTextColor)
                        .multilineTextAlignment(.center)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)//
                    
                    Text("What's your password?")
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
                    
                    Task {
                        await AuthenticationManager.shared.signIn(email: emailBinding.wrappedValue, password: passwordBinding.wrappedValue)
                    }
                    
                    UIApplication.shared.endEditing()
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
//                    Task {
//                        await AuthenticationManager.shared.signIn(email: emailBinding.wrappedValue, password: passwordBinding.wrappedValue)
//                    }
//
//                    UIApplication.shared.endEditing()
////                    self.state = .authenticated
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

struct LoginView_Previews: PreviewProvider {
    @State static var state = AccountState.login
    
    static var previews: some View {
        LoginView()
    }
}
