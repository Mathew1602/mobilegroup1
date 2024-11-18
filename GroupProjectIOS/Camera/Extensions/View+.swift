//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//

import SwiftUI

extension View {
    func fullScreenCamera(isPresented: Binding<Bool>, imageData: Binding<Data?>) -> some View {
        self
            .fullScreenCover(isPresented: isPresented) {
                CameraView(isPresented: isPresented, imageData: imageData)
            }
    }
}
