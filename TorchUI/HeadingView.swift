//
//  HeadingView.swift
//  TorchUI
//
//  Created by Parth Saxena on 9/7/23.
//

import SwiftUI

struct HeadingView: View {
    @Environment(\.colorScheme) var colorScheme
    let height: CGFloat = 120
    let width: CGFloat = UIScreen.main.bounds.width
    let opacity = 0.2
    
    var body: some View {
        ZStack {
            HStack {
                ZStack {
//                    Rectangle()
//                        .ignoresSafeArea()
//                        .frame(width: width, height: height)
//                        .background(Color.white)
//                        .padding(.top, 30)
                    
//                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .top, endPoint: .bottom)
//                        .ignoresSafeArea()
//                        .frame(width: width, height: height)
//                        .padding(.top, 30)
//                        .opacity(0.01)
//                        .blur(radius: 5.0)
                    
                    VisualEffectView(effect: UIBlurEffect(style: (colorScheme == .dark) ? .dark : .light))
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: width, height: height)
                        .padding(.top, 30)
                    
                    HStack {
                        Text("Home")
                            .font(Font.custom("Manrope-SemiBold", size: 36))
                            .foregroundColor(colorScheme == .dark ? CustomColors.DarkModeMainTestColor : CustomColors.TorchGreen)
                            .multilineTextAlignment(.center)
                            
                        Spacer()
                        
                        Image("Avatar")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 48, height: 48)
                            .clipped()
                            .cornerRadius(100)
                            .shadow(color: Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.03), radius: 4, x: 0, y: 8)
                            .shadow(color: Color(red: 0.18, green: 0.21, blue: 0.22).opacity(0.08), radius: 12, x: 0, y: 20)
                            .onTapGesture {
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                                
                                Task {
                                    await AuthenticationManager.shared.signOut()
                                }
                            }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 100)
                    .padding(.bottom, 20)
                }
            }
            .frame(width: width, height: height)
            .ignoresSafeArea()
        }
    }
}

struct HeadingView_Previews: PreviewProvider {
    static var previews: some View {
        HeadingView()
    }
}
