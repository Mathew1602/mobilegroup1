//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//

import SwiftUI

struct ImageView: View {
    
    let imgData: Data?
    
    var body: some View {
        if let imgData, let uiImage = UIImage(data: imgData) {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    ImageView(imgData: nil)
        .padding()
}
