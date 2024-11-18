//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//

import SwiftUI

extension CameraView {

    var capturePhotoButton: some View {
        Button {
            switch VM.photoCaptureState {
            case .notStarted: // only take photo when photo capture process has not yet started
                VM.takePic()
            default:
                return // do nothing
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 65)
                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 75)
            }
        }
        .padding(5)
    }
    
    var cancelButton: ControlBarButton {
        ControlBarButton(label: String(localized: "Cancel")) {
            isPresented = false
        }
    }
    
    var retakePhotoButton: ControlBarButton {
        ControlBarButton(label: String(localized: "Retake")) {
            VM.retakePic()
        }
    }
    
    var usePhotoButton: ControlBarButton {
        ControlBarButton(label: String(localized: "Use Photo")) {
            imageData = VM.photoData
            isPresented = false
        }
    }
}
