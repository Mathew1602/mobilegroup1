//
//  Untitled.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-24.
//

import SwiftUI
import PhotosUI


struct PhotoPickerView : UIViewControllerRepresentable {
    
    
    @Binding var imageData: UIImage?
    
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
    }
    
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        init(parent: PhotoPickerView) {
            self.parent = parent
        }
        
        let parent: PhotoPickerView
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.isPresented = false

            if results.count != 1 {
                print("Error: result count != 1")
                return
            }
            
            guard let provider = results.first?.itemProvider, provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    if let uiImage = image as? UIImage {
                        self.parent.imageData = uiImage
                    } else {
                        print("Error: Could not load image.")
                    }
                }
            }
        }
    }
}
