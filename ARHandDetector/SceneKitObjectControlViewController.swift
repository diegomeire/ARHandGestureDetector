//
//  ARObjectTrackingViewController.swift
//  ARHandDetector
//
//  Created by Diego Meire on 12/02/20.
//  Copyright © 2020 Diego Meire. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import CoreML
import Vision

class SceneKitObjectControlViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var previewView = UIImageView()
    
    var currentBuffer: CVPixelBuffer?
    
    var touchNode = SCNNode()
   
    ///
    func showAlert( _ message: String ){
        
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
              switch action.style{
              case .default:
                    print("default")

              case .cancel:
                    print("cancel")

              case .destructive:
                    print("destructive")
              @unknown default:
                fatalError()
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func moveObject( at point: CGPoint){
        
        // Compute near & far points
        let nearVector = SCNVector3(x: Float(point.x), y: Float(point.y), z: 0)
        let nearScenePoint = sceneView!.unprojectPoint(nearVector)
        
        let farVector = SCNVector3(x: Float(point.x), y: Float(point.y), z: 1 )
        let farScenePoint = sceneView!.unprojectPoint(farVector)
        
        // Compute view vector
        let viewVector = SCNVector3(x: Float(farScenePoint.x - nearScenePoint.x),
                                    y: Float(farScenePoint.y - nearScenePoint.y),
                                    z: Float(farScenePoint.z - nearScenePoint.z))
        
        // Normalize view vector
        let vectorLength = sqrt(viewVector.x*viewVector.x + viewVector.y*viewVector.y + viewVector.z*viewVector.z)
        let normalizedViewVector = SCNVector3(x: viewVector.x/vectorLength, y: viewVector.y/vectorLength, z: viewVector.z/vectorLength)
        
        // Scale normalized vector to find scene point
        let scale : Float = Float( 1 / Float( previewView.bounds.size.width ) ) * 5000
        
        let scenePoint = SCNVector3(x: normalizedViewVector.x*scale,
                                    y: normalizedViewVector.y*scale,
                                    z: normalizedViewVector.z*scale )
        
        
        
        touchNode.position = scenePoint
        
    }
    
    
    override func loadView() {
        super.loadView()

        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // We want to receive the frames from the video
        sceneView.session.delegate = self

        // Run the session with the configuration
        sceneView.session.run(configuration)

        view.addSubview(previewView)

        previewView.translatesAutoresizingMaskIntoConstraints = false
        previewView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        previewView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    
        sceneView.scene = SCNScene(named: "art.scnassets/default.scn")!
        
        let sphere = SCNSphere(radius: 1)
        touchNode = SCNNode(geometry: sphere)
        
        sceneView.scene.rootNode.addChildNode(touchNode)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        // We return early if currentBuffer is not nil or the tracking state of camera is not normal
        guard currentBuffer == nil, case .normal = frame.camera.trackingState else {
            return
        }

        // Retain the image buffer for Vision processing.
        currentBuffer = frame.capturedImage

        startDetection()
    }
    
    
    let handDetector = HandDetector()
    let handGestureDetector = HandGestureDetector()
    var alpha: CGFloat = 0
    
    private func startDetection() {
        // To avoid force unwrap in VNImageRequestHandler
        guard let buffer = currentBuffer else { return }

        handDetector.performDetection(inputBuffer: buffer) { outputBuffer, _ in
            // Here we are on a background thread
            var previewImage: UIImage?
            var normalizedFingerTip: CGPoint?

            defer {
                DispatchQueue.main.async {
                    self.previewView.image = previewImage

                    // Release currentBuffer when finished to allow processing next frame
                    self.currentBuffer = nil

                    self.touchNode.isHidden = true
                    
                    
                    guard let tipPoint = normalizedFingerTip else {
                        return
                    }

                    // We use a coreVideo function to get the image coordinate from the normalized point
                    let imageFingerPoint = VNImagePointForNormalizedPoint(tipPoint, Int(self.view.bounds.size.width), Int(self.view.bounds.size.height))

                    
                    self.moveObject(at: imageFingerPoint)
                    self.touchNode.isHidden = false
                    
                    
                    /*
                    
                    // And here again we need to hitTest to translate from 2D coordinates to 3D coordinates
                    let hitTestResults = self.sceneView.hitTest(imageFingerPoint, types: .existingPlaneUsingExtent)
                    guard let hitTestResult = hitTestResults.first else { return }

                    // We position our touchNode slighlty above the plane (1cm).
                    self.touchNode.simdTransform = hitTestResult.worldTransform
                    self.touchNode.position.y += 0.01
                    self.touchNode.isHidden = false
                     */
                    
                }
            }

            guard let outBuffer = outputBuffer else {
                return
            }

            // Create UIImage from CVPixelBuffer
            previewImage = UIImage(ciImage: CIImage(cvPixelBuffer: outBuffer))

            normalizedFingerTip = outBuffer.searchTopPoint()
           
        }
        
        /*
        handGestureDetector.performDetection(inputBuffer: buffer) { (retorno, _) in
            
               var symbol = "❎"
               let topPrediction = retorno.components(separatedBy: "\n")[0]
               let topPredictionName = retorno.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
               // Only display a prediction if confidence is above 1%
               let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
               if (topPredictionScore != nil && topPredictionScore! > 0.01) {
                   if (topPredictionName == "fist-UB-RHand") {
                        symbol = "👊"
                        self.holdingHandsCounter = self.holdingHandsCounter + 1
                        
                    }
                   if (topPredictionName == "FIVE-UB-RHand") {
                      symbol = "🖐"
                      self.holdingHandsCounter = 0
                   }
               }
                
               if (self.holdingHandsCounter > 5){
                  self.cursorView?.setColor(.red)
               }
               else{
                    self.cursorView?.setColor(.blue)
               }
            
            print( symbol )
        }*/
        
    }
    
}