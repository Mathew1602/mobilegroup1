//
//  CameraViewInTabView.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-11.
//

// CameraViewInTabView.swift
// GroupProjectIOS

import SwiftUI

struct CameraViewInTabView: View {
    @Binding var isPresented: Bool
    @Binding var imageData: Data?
    
    var body: some View {
        CameraView(isPresented: $isPresented, imageData: $imageData)
    }
}

#Preview {
    CameraView(isPresented: .constant(true), imageData: .constant(nil))
}
