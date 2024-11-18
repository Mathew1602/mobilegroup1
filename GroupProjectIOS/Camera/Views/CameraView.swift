//
//  CameraView.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//


import SwiftUI

public struct CameraView: View {
    @Environment(\.verticalSizeClass) private var vertiSizeClass
    
    @Binding var isPresented: Bool
    @Binding var imageData: Data?
    
    @State internal var VM = CameraViewModel()
    
    internal let controlButtonWidth: CGFloat = 120
    internal let controlFrameHeight: CGFloat = 90
    
    public init(isPresented: Binding<Bool>, imageData: Binding<Data?>) {
        self._isPresented = isPresented
        self._imageData = imageData
    }
    
    var isLandscape: Bool { vertiSizeClass == .compact }
    
    public var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            cameraAndControlView
        }
        .onAppear {
        #if targetEnvironment(simulator)
        print("Camera is not available on the simulator.")
        return
        #endif
            VM.requestAccessAndSetup()
            VM.resumeSession()
        }
        .onDisappear {
        #if targetEnvironment(simulator)
        print("Camera is not available on the simulator.")
        return
        #endif
            VM.stopSession()
        }
        .toolbar(.hidden, for: .navigationBar)
    }
    
    var cameraAndControlView: some View {
        VStack {
            HStack {
                FramedCameraPreview(VM: VM)
                if isLandscape {
                    controlBar(style: .vertical)
                        .ignoresSafeArea()
                }
            }
            if !isLandscape {
                controlBar(style: .horizontal)
                    .padding(.bottom)
            }
        }
    }
    
    @ViewBuilder func controlBar(style: CameraControlBarStyle) -> some View {
        switch style {
            case .horizontal: horizontalControlBar
            case .vertical: verticalControlBar
        }
    }
}



#Preview {
    CameraView(isPresented: .constant(true), imageData: .constant(nil))
}
