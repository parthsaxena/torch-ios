//
//  PropertyPhotoView.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/10/23.
//

import SwiftUI

struct PropertyPhotoView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
//    @StateObject var vm: PropertyPhotoViewModel
    
    @Binding var state: OnboardingState
    var propertyName: String
    var propertyAddress: String
//    @State var (focusedField != .field): Bool = false
    
    // place holder text color
    @State var fieldTextColor: Color = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
    
    // disabled button color
    @State var nextButtonColor: Color = Color(red: 0.78, green: 0.81, blue: 0.82)
    @State var nextButtonEnabled: Bool = false

    @State var googleMapsImageSelected: Bool = false
    
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
                        AddPropertyBackButton(state: self.$state)
                        
                        Spacer()
                    }
                    .padding(.leading, 15.0)
                    
                    HStack {
                        Spacer()
                        
                        VStack {
                            Text(self.propertyName)
                                .kerning(-0.5)
                                .font(Font.custom("Manrope-SemiBold", size: 18.0))
                                .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                            
                            Spacer()
                                .frame(height: 4)
                            
                            Text(self.propertyAddress)
                                .kerning(-0.5)
                                .multilineTextAlignment(.center)
                                .font(Font.custom("Manrope-Medium", size: 14.0))
                                .foregroundColor(Color(red: 0.45, green: 0.53, blue: 0.55))
                                .frame(maxWidth: 250)
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
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
                
//                Text(self.propertyAddress)
//                    .font(Font.custom("Manrope-Medium", size: 14.0))
//                    .foregroundColor(Color(red: 0.45, green: 0.53, blue: 0.55))
                
                Spacer()
                
                HStack {
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            
                            // add photo
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color(red: 0.945, green: 0.953, blue: 0.953))
                                .frame(width: 120, height: 120)
                                .overlay(
                                    ZStack {
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 32, height: 32)
                                        
                                        Image(systemName: "plus")
                                            .foregroundColor(Color(red: 143.0/255.0, green: 160.0/255.0, blue: 163.0/255.0))
                                    }
                                )
                            
                            Spacer()
                                .frame(width: 25)
                            
                            ZStack {
                                var urlString = "\(imageApiUrl)\(self.propertyAddress)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!                                
                                
                                Rectangle()
                                  .foregroundColor(.clear)
                                  .frame(width: 120, height: 120)
                                  .background(self.googleMapsImageSelected ? Color(red: 0.08, green: 0.44, blue: 0.94).opacity(0.1) : Color.clear)
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
                                  .onTapGesture {
                                      let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                      impactMed.impactOccurred()
                                      
                                      self.googleMapsImageSelected.toggle()
                                      
                                      if self.googleMapsImageSelected {
                                          nextButtonEnabled = true
                                          nextButtonColor = Color(red: 0.18, green: 0.21, blue: 0.22)
                                      } else {
                                          nextButtonEnabled = false
                                          nextButtonColor = Color(red: 0.78, green: 0.81, blue: 0.82)
                                      }
                                      
                                  }
                                
                                if (self.googleMapsImageSelected) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(Font.system(size: 24))
                                        .foregroundStyle(Color.white, Color.blue)
                                        .clipped()
                                }
                            }
                            .shadow(color: self.googleMapsImageSelected ? Color(red: 0.08, green: 0.44, blue: 0.94).opacity(0.6) : Color.clear, radius: 4, x: 0, y: 0)


                            
                            Spacer()
                        }
                        
                        Text("You can add a photo yourself or choose a\nsuggested one from Google")
                            .font(Font.custom("Manrope-Medium", size: 16.0))
                            .foregroundColor(Color(red: 0.45, green: 0.53, blue: 0.55))
                            .multilineTextAlignment(.center)
                            .padding(.top, self.googleMapsImageSelected ? 43 : 40)
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
                        SessionManager.shared.newProperty?.propertyImage = urlString
                        SessionManager.shared.newProperty?.loadingData = true
                        state = .promptInstallation
                        
                        SessionManager.shared.uploadNewProperty()
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
                    
//                    Button("Next") {
//                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
//                        impactMed.impactOccurred()
//
//                        var urlString = "\(imageApiUrl)\(self.propertyAddress)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
//                        SessionManager.shared.newProperty?.propertyImage = urlString
//                        state = .promptInstallation
//
//                        SessionManager.shared.uploadNewProperty()
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
                .padding(.top, 60)
            }
        }
    }
}

struct ContentView3: View {
    @State private var showingSheet = true
    @State var state = OnboardingState.propertyPhoto
//    @State var propertyName


    var body: some View {
//        AddPropertySheetView()
//        PromptInstallationView(state: $state, propertyName: "Mom's house", propertyAddress: "Pacific Coast Hwy, Malibu, CA 94588")
        PropertyPhotoView(state: $state, propertyName: "Mom's house", propertyAddress: "USA Pacific Coast Hwy, Malibu, CA 90265aa")
    }
}

struct PropertyPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView3()
    }
}
