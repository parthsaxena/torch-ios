//
//  PromptInstallationView.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/12/23.
//

import SwiftUI

struct PromptInstallationView: View {
    @Environment(\.dismiss) var dismiss
    
//    @StateObject var vm: PromptInstallationViewModel
    
    @Binding var state: OnboardingState
    var propertyName: String
    var propertyAddress: String
//    @State var (focusedField != .field): Bool = false
    
    // place holder text color
    @State var fieldTextColor: Color = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
    
    // disabled button color
    @State var nextButtonColor: Color = Color(red: 0.18, green: 0.21, blue: 0.22)
    @State var nextButtonEnabled: Bool = true
    
    let imageApiUrl = "https://maps.googleapis.com/maps/api/staticmap?key=AIzaSyBevmebTmlyD-kftwvRqqRItgh07CDiwx0&size=180x180&scale=2&maptype=satellite&zoom=19&center="
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 3) {
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
                        Text("Property \(self.propertyName) is set up!")
                            .kerning(-0.5)
                            .font(Font.custom("Manrope-SemiBold", size: 18.0))
                            .foregroundColor(CustomColors.TorchGreen)
                        
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
                
                // Property photo, name, address
                HStack {
                    Spacer()
                    VStack(spacing: 10) {
                        // Property photo
                        HStack {
                            Spacer()
                            
                            var urlString = "\(imageApiUrl)\(self.propertyAddress)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
                            Rectangle()
                              .foregroundColor(.clear)
                              .frame(width: 120, height: 120)
                              .background(
                                
                                AsyncImage(url: URL(string: urlString)) { image in
                                    image.resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 120, height: 120)
                                        .clipped()
                                } placeholder: {
                                    ProgressView()
                                }
                              )
                              .cornerRadius(24)
                              .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                  .inset(by: 1)
                                  .stroke(.white, lineWidth: 2)
                              )


                            
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height: 1)
                        
                        // Property name
                        Text(propertyName)
                            .font(Font.custom("Manrope-SemiBold", fixedSize: 30.0))
                            .foregroundColor(CustomColors.TorchGreen)
                        
                        // Property address
                        Text(propertyAddress)
                            .font(Font.custom("Manrope-Medium", size: 16.0))
                            .foregroundColor(Color(red: 0.45, green: 0.53, blue: 0.55))
                            .multilineTextAlignment(.center)
                    }
                        //                        .padding(.top, 5.0)
                    Spacer()
                }
                
                Spacer()
                
                // Next button
                HStack {
                    Spacer()
                    Button(action: {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                        
                        var urlString = "\(imageApiUrl)\(self.propertyAddress)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//                        SessionManager.shared.newProperty = Property(id: "0", propertyName: propertyName, propertyAddress: propertyAddress, propertyImage: urlString)
                        SessionManager.shared.selectedProperty = SessionManager.shared.newProperty
                        
                        self.state = .placeSensors
                    }) {
                        Text("Set up sensors for \(propertyName)")
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
                    
//                    Button("Set up sensors for \(propertyName)") {
//                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                        impactMed.impactOccurred()
//
//                        var urlString = "\(imageApiUrl)\(self.propertyAddress)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
////                        SessionManager.shared.newProperty = Property(id: "0", propertyName: propertyName, propertyAddress: propertyAddress, propertyImage: urlString)
//                        SessionManager.shared.selectedProperty = SessionManager.shared.newProperty
//
//                        self.state = .placeSensors
//                    }
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
                
                HStack {
                    Spacer()
                    
                    Text("Go to home screen")
                        .font(Font.custom("Manrope-SemiBold", size: 16.0))
                        .foregroundColor(CustomColors.LightGray)
                        .onTapGesture {
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
                            dismiss()
                        }
                    
                    Spacer()
                }
//                .padding(.top, 60)
            }
        }
    }
}

//struct ContentView4: View {
//    @State private var showingSheet = true
//    @State var state = OnboardingState.promptInstallation
////    @State var propertyName
//
//
//    var body: some View {
////        AddPropertySheetView()
//        PromptInstallationView(state: $state, propertyName: "Mom's house", propertyAddress: "Pacific Coast Hwy, Malibu, CA 94588")
//    }
//}
//
//struct PromptInstallationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView4()
//    }
//}

