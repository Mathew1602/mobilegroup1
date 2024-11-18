//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-10.
//

import SwiftUI
import AVFoundation

extension CameraViewModel: AVCapturePhotoCaptureDelegate {
    
    enum PhotoOutputError: Error {
        case noImageData
        case noCGDataProvider
        case noCGImage
        case orientationError
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error {
            print(error.localizedDescription)
            self.photoCaptureState = .error(error)
            return
        }
        guard let imageData = photo.fileDataRepresentation() else {
            self.photoCaptureState = .error(PhotoOutputError.noImageData)
            return
        }
        guard let provider = CGDataProvider(data: imageData as CFData) else {
            print("no provider")
            self.photoCaptureState = .error(PhotoOutputError.noCGDataProvider)
            return
        }
        guard let cgImage = CGImage(jpegDataProviderSource: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent) else {
            print("no cgimage")
            self.photoCaptureState = .error(PhotoOutputError.noCGImage)
            return
        }
        
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning()
            DispatchQueue.main.async {
                let orientation = UIDevice.current.orientation
                let image = UIImage(cgImage: cgImage, scale: 1, orientation: orientation.uiImageOrientation)
                let imageData = image.pngData()
                withAnimation {
                    if let imageData {
                        self.photoCaptureState = .finished(imageData)
                    } else {
                        self.photoCaptureState = .error(PhotoOutputError.orientationError)
                    }
                }
            }
        }
        
        
    }
    
}
