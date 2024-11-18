//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//

import SwiftUI

struct FramedCameraPreview: View {
    @Bindable var VM: CameraViewModel
    
    var body: some View {
        GeometryReader { geometry in
            CameraPreview(cameraVM: VM, frame: geometry.frame(in: .global))
                .onAppear() {
                    VM.requestAccessAndSetup()
                }
                .ignoresSafeArea()
        }
    }
}
