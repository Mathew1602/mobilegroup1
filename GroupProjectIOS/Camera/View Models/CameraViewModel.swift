//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//

import SwiftUI
import AVFoundation

import SwiftUI
import AVFoundation

@Observable
class CameraViewModel: NSObject {
    
    enum PhotoCaptureState {
        case notStarted
        case inProgress
        case finished(Data)
        case error(Error)
    }
    
    // MARK: Vars
    
    var didRequestAccessFail: Bool = false
    var isSetup: Bool = false
    
    var session = AVCaptureSession()
    var preview = AVCaptureVideoPreviewLayer()
    var output = AVCapturePhotoOutput()
    
    var photoCaptureState: PhotoCaptureState = .notStarted
    var photoData: Data? {
        switch photoCaptureState {
            case .finished(let data): return data
            default: return nil
        }
    }
    var hasPhoto: Bool { photoData != nil }
    
    // MARK: Funcs
    
    func resumeSession() {
        if !session.isRunning {
            Task(priority: .background) {
                session.startRunning()
            }
        }
    }

    
    func requestAccessAndSetup() {
        //Code to prevent simulator from crashing
        //because camera is not avaiable
        if #available(iOS 15, *) {
            #if targetEnvironment(simulator)
            print("Camera is not available on the simulator.")
            return
            #endif
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { didAllow in
                if didAllow {
                    self.setUp()
                }
            }
        case .restricted, .denied:
            didRequestAccessFail = true
        case .authorized:
            setUp()
        @unknown default:
            print("unknown AVCaptureDevice.authorizationStatus value: \(AVCaptureDevice.authorizationStatus(for: .video))")
        }
    }
    
    func setUp() {
        if isSetup { return }
        do {
            session.beginConfiguration()
            session.sessionPreset = .photo
            
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            let input = try AVCaptureDeviceInput(device: device)
            
            guard session.canAddInput(input) else { return }
            session.addInput(input)
            
            guard session.canAddOutput(output) else { return }
            session.addOutput(output)
            
            session.commitConfiguration()
            isSetup = true
            
            Task(priority: .background) {
                session.startRunning()
                await MainActor.run {
                    let orientation = UIDevice.current.orientation
                    preview.connection?.videoRotationAngle = orientation.videoRotationAngle
                }
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopSession() {
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    func takePic() {
        output.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        withAnimation {
            photoCaptureState = .inProgress
        }
    }
    
    func retakePic() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
            DispatchQueue.main.async {
                withAnimation {
                    self.photoCaptureState = .notStarted
                }
            }
        }
    }
}
