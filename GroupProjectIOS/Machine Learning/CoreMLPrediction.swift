//
//  CoreMLPredictionManager.swift
//  GroupProjectIOS
//
//  Created by Mathew Boyd on 2024-11-24.
//

import CoreML
import UIKit

class CoreMLPrediction{
    private let model: MLModel
    private let classNames = ["donuts", "pancakes", "pizza", "waffles"]
    
    init() {
        // Load the Core ML model
        guard let modelURL = Bundle.main.url(forResource: "FoodClassifier", withExtension: "mlmodelc"),
              let loadedModel = try? MLModel(contentsOf: modelURL) else {
            fatalError("Failed to load the Core ML model.")
        }
        self.model = loadedModel
    }
    
    func predictFood(from image: UIImage, completion: @escaping (String, Double) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let resizedImage = self.resizeImage(image, size: CGSize(width: 224, height: 224)),
                  let pixelBuffer = self.imageToPixelBuffer(resizedImage) else {
                print("Failed to process the image.")
                return
            }
            
            do {
                let prediction = try self.model.prediction(from: MLDictionaryFeatureProvider(
                    dictionary: ["sequential_16_input": pixelBuffer]
                ))
                
                if let logits = prediction.featureValue(for: "Identity")?.multiArrayValue {
                    let probabilities = self.softmax(logits: logits)
                    if let (predictedIndex, confidence) = self.getTopPrediction(probabilities: probabilities) {
                        let predictedClass = self.classNames[predictedIndex]
                        DispatchQueue.main.async {
                            completion(predictedClass, confidence * 100.0)
                        }
                    }
                }
            } catch {
                print("Error making prediction: \(error)")
            }
        }
    }
    
    private func softmax(logits: MLMultiArray) -> [Double] {
        var logitsArray: [Double] = []
        
        for i in 0..<logits.count {
            logitsArray.append(logits[i].doubleValue)
        }
        
        let expScores = logitsArray.map { exp($0 - logitsArray.max()!) }
        let sumExpScores = expScores.reduce(0, +)
        return expScores.map { $0 / sumExpScores }
    }

    
    private func getTopPrediction(probabilities: [Double]) -> (Int, Double)? {
        guard let maxProbability = probabilities.max(),
              let index = probabilities.firstIndex(of: maxProbability) else { return nil }
        return (index, maxProbability)
    }
    
    private func resizeImage(_ image: UIImage, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    private func imageToPixelBuffer(_ image: UIImage) -> CVPixelBuffer? {
        let attributes: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey: true
        ]
        var pixelBuffer: CVPixelBuffer?
        let width = Int(image.size.width)
        let height = Int(image.size.height)
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32ARGB, attributes as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        )
        
        guard let cgImage = image.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}
