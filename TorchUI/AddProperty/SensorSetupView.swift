//
//  SensorSetupView.swift
//  TorchUI
//
//  Created by Parth Saxena on 7/13/23.
//

import SwiftUI

struct SensorSetupView: View {
    @Environment(\.dismiss) var dismiss
    
//    @StateObject var vm: SensorSetupViewModel
    
    @Binding var state: OnboardingState
    var propertyName: String
    var propertyAddress: String
//    @State var (focusedField != .field): Bool = false
    
    // place holder text color
    @State var fieldTextColor: Color = Color(red: 171.0/255.0, green: 183.0/255.0, blue: 186.0/255.0)
    
    // disabled button color
    @State var nextButtonColor: Color = Color(red: 0.18, green: 0.21, blue: 0.22)
    @State var nextButtonEnabled: Bool = true
    
    @State private var data: [DataItem] = [
            DataItem(title: "1", size: 60, color: .green),
            DataItem(title: "2", size: 60, color: .red),
            DataItem(title: "3", size: 60, color: .blue),
            DataItem(title: "4", size: 60, color: .orange),
            DataItem(title: "5", size: 60, color: .yellow),
            DataItem(title: "6", size: 60, color: .green),
            DataItem(title: "7", size: 60, color: .red),
            DataItem(title: "8", size: 60, color: .blue),
            DataItem(title: "9", size: 60, color: .orange),
            DataItem(title: "10", size: 60, color: .mint)
        ]
    let imageApiUrl = "https://maps.googleapis.com/maps/api/staticmap?key=AIzaSyBevmebTmlyD-kftwvRqqRItgh07CDiwx0&size=180x180&scale=2&maptype=satellite&zoom=19&center="
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 3) {
                // Heading
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 48.0, height: 48.0)
                        Image(systemName: "chevron.backward")
                            .frame(width: 48.0, height: 48.0)
                            .foregroundColor(CustomColors.TorchGreen)
                        Button {
                            withAnimation {
//                                showDetectorDetails = false
                            }
                        } label: {
                            Circle()
                                .fill(Color.clear)
                                .frame(width: 60.0, height: 60.0)
                        }
                    }
                    .shadow(color: CustomColors.LightGray, radius: 15.0)
                    
                    Spacer()
                }
                .padding(.top, 20)
                .padding(.leading, 20)
                
                Spacer()
                
                BubbleView(data: $data, spacing: 0, startAngle: 180, clockwise: true)
                            .font(.caption)
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: .infinity)
                            .border(Color.red)
                
                // Next button
                HStack {
                    Spacer()
                    Button("Set up sensors for \(propertyName)") {
                        let impactMed = UIImpactFeedbackGenerator(style: .medium)
                        impactMed.impactOccurred()
                    }
                    .disabled(!nextButtonEnabled)
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
                    Spacer()
                }
            }
        }
    }
}

struct SensorSetupView_Previews: PreviewProvider {
    @State static var state = OnboardingState.connectToHub
    static let propertyName = "Mom's house"
    static let propertyAddress = "2237 Kamp Ct, Pleasanton, CA 94588"
    
    static var previews: some View {
        SensorSetupView(state: $state, propertyName: propertyName, propertyAddress: propertyAddress)
    }
}
