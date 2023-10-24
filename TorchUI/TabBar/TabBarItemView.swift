//
//  TabBarItemView.swift
//  TorchUI
//
//  Created by Parth Saxena on 6/28/23.
//

import SwiftUI

struct TabBarItemData {
    let image: String
    let selectedImage: String
    let size: CGFloat
}

struct TabBarItemView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let data: TabBarItemData
    let isSelected: Bool
    
    var body: some View {
        VStack {
            if data.image == "main-nav" {
                Image(isSelected ? data.image : data.image)
                    .resizable()
//                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: data.size, height: data.size)
//                    .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
//                    .foregroundColor(isSelected ? Color(red: 1, green: 0.36, blue: 0.14) : CustomColors.TorchGreen)
                    .animation(.default)
                    .padding(.top, 20)
            } else {
                Image(isSelected ? data.image : data.image)
                    .resizable()
                    .renderingMode(.template)
                    .aspectRatio(contentMode: .fit)
//                    .foregroundColor(colorScheme == .dark ? Color.white : CustomColors.TorchGreen)
                    .foregroundColor(isSelected ? Color(red: 1, green: 0.36, blue: 0.14) : (colorScheme == .dark ? Color.white : CustomColors.TorchGreen))
                    .frame(width: data.size, height: data.size)
                    .animation(.default)
                    .padding(.top, 20)
            }
            
            Circle()
                .fill(isSelected ? Color(red: 1, green: 0.36, blue: 0.14) : Color.clear)
                .frame(width: 5, height: 5)
        }
    }
}
