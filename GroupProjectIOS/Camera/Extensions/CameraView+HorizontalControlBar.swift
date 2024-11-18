//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//

import SwiftUI

extension CameraView  {
    
    @ViewBuilder var horizontalControlBar: some View {
        if VM.photoData != nil {
            horizontalControlBarPostPhoto
                .frame(height: controlFrameHeight, alignment: .center)
        } else {
            horizontalControlBarPrePhoto
                .frame(height: controlFrameHeight, alignment: .center)
        }
    }
    
    var horizontalControlBarPrePhoto: some View {
        HStack {
            cancelButton
                .frame(width: controlButtonWidth, alignment: .center)
            Spacer()
            capturePhotoButton
            Spacer()
            Spacer()
                .frame(width: controlButtonWidth)
        }
    }
    
    var horizontalControlBarPostPhoto: some View {
        HStack {
            retakePhotoButton
            Spacer()
            usePhotoButton
        }
        .padding(.horizontal)
        .padding(.horizontal)
    }
    
}
