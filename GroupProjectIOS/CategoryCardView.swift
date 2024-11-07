//
//  CategoryCardView.swift
//  GroupProjectIOS
//
//  Created by Xiaoya Zou on 2024-11-06.
//

import SwiftUI

struct CategoryCardView: View {
    var category: FoodCategory

    var body: some View {
        VStack {
            Image(category.imageName)
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(category.name)
                .font(.headline)
                .foregroundColor(.primary)
                .padding()
        }
        .frame(width: 170, height: 170)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray, lineWidth: 0.5)
        )
        .cornerRadius(12)
//        .shadow(radius: 2)
    }
}

#Preview {
    CategoryCardView(category: FoodCategory(name: "Default Category", imageName: "image"))
}
