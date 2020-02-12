//
//  HandGestureDetector.swift
//  ARHandDetector
//
//  Created by Diego Meire on 11/02/20.
//  Copyright © 2020 Diego Meire. All rights reserved.
//

import CoreML
import Vision

public class HandGestureDetector {
 
    // MARK: - Variables
    private let visionQueue = DispatchQueue(label: "com.diegomeire.handgesture")

    private lazy var predictionRequest: VNCoreMLRequest = {
        // Load the ML model through its generated class and create a Vision request for it.
        do {
            let model = try VNCoreMLModel(for: HandGesture().model)
            let request = VNCoreMLRequest(model: model)

            // This setting determines if images are scaled or cropped to fit our 224x224 input size. Here we try scaleFill so we don't cut part of the image.
            request.imageCropAndScaleOption = VNImageCropAndScaleOption.scaleFill
            
            return request
        } catch {
            fatalError("can't load Vision ML model: \(error)")
        }
    }()

    
    
    // MARK: - Public functions
    public func performDetection(inputBuffer: CVPixelBuffer, completion: @escaping (_ output: String, _ error: Error?) -> Void) {
        // Right orientation because the pixel data for image captured by an iOS device is encoded in the camera sensor's native landscape orientation
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: inputBuffer, orientation: .right)

        // We perform our CoreML Requests asynchronously.
        visionQueue.async {
            // Run our CoreML Request
            do {
                try requestHandler.perform([self.predictionRequest])

                guard let observations = self.predictionRequest.results else {
                    fatalError("Unexpected result type from VNCoreMLRequest")
                }
                
                // Get Classifications
                let classifications = observations[0...2] // top 3 results
                    .compactMap({ $0 as? VNClassificationObservation })
                    .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
                    .joined(separator: "\n")
                
                print( classifications )
                
                // The resulting image (mask) is available as observation.pixelBuffer
                completion(classifications, nil)
            } catch {
                completion("", error)
            }
        }
    }

}
