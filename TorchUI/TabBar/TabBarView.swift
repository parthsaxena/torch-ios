//
//  TabBarView.swift
//  TorchUI
//
//  Created by Parth Saxena on 6/28/23.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct TabBarView: View {
//    @State private var showingSheet = false
    @Environment(\.colorScheme) var colorScheme
    
    let tabBarItems: [TabBarItemData]
    let height: CGFloat = 100
    let width: CGFloat = UIScreen.main.bounds.width
    let opacity = 0.2
    let shadowRadius: CGFloat = 5.0
    let shadowX: CGFloat = 0.0
    let shadowY: CGFloat = 4.0
    @Binding var selectedIndex: Int
    
    var body: some View {
        ZStack {
            HStack {
                ZStack {
//                    Rectangle()
//                        .ignoresSafeArea()
//                        .frame(width: width, height: height)
//                        .background(Color.white)
//                        .padding(.top, 30)
                    
                    LinearGradient(gradient: Gradient(colors: [Color.black, Color.black]), startPoint: .top, endPoint: .bottom)
                        .ignoresSafeArea()
                        .frame(width: width, height: height)
                        .padding(.top, 30)
                        .opacity(0.01)
//                        .blur(radius: 5.0)
                    
                    VisualEffectView(effect: UIBlurEffect(style: (colorScheme == .dark) ? .dark : .light))
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: width, height: height)
                        .padding(.top, 30)
                    
                    HStack {
                        Spacer()
                        
                        ForEach(tabBarItems.indices) { index in
                            let item = tabBarItems[index]
                            Button {
                                // print("selected index: \(index)")
                                self.selectedIndex = index
                                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                                impactMed.impactOccurred()
                            } label: {
                                let isSelected = selectedIndex == index
                                TabBarItemView(data: item, isSelected: isSelected)
//                                    .background(Color.yellow)
                            }
                            Spacer()
                        }
                    }
                }
            }
            .frame(width: width, height: height)
//            .shadow(radius: shadowRadius, x: shadowX, y: shadowY)
        }
    }
}

struct TabBarView_Previews: PreviewProvider {
    @State static var selectedIndex: Int = 0
    
    static var previews: some View {
        PropertiesView()
//        VStack {
//            Spacer()
//            ZStack {
//                TabBarView(tabBarItems: [
//                    TabBarItemData(image: "home", selectedImage: "home"),
//                    TabBarItemData(image: "search", selectedImage: "web-icon"),
//                    TabBarItemData(image: "main-nav", selectedImage: "roster-icon"),
//                    TabBarItemData(image: "notif", selectedImage: "match-icon"),
//                    TabBarItemData(image: "settings", selectedImage: "match-icon")], selectedIndex: $selectedIndex)
//            }
//        }
    }
}
