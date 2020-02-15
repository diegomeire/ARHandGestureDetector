//
//  ARBubblePopperViewController.swift
//  ARHandDetector
//
//  Created by Diego Meire on 13/02/20.
//  Copyright © 2020 Diego Meire. All rights reserved.
//

import Foundation
import UIKit
import ARKit
import CoreML
import Vision

class ARBubblePopperViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    var previewView = UIImageView()
    
    var currentBuffer: CVPixelBuffer?
    
    var bubbles = [Bubble]()
    
    var spawnedBubbles = false
    
    var bubbleScheduler : Timer?
    
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
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    
        addBubbles(on: sceneView.scene.rootNode)
      
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

                    guard let tipPoint = normalizedFingerTip else {
                        return
                    }

                    // We use a coreVideo function to get the image coordinate from the normalized point
                    let imageFingerPoint = VNImagePointForNormalizedPoint( tipPoint,
                                                                           Int(self.view.bounds.size.width),
                                                                           Int(self.view.bounds.size.height))

                    
                    // And here again we need to hitTest to translate from 2D coordinates to 3D coordinates
                    let hitTestResults = self.sceneView.hitTest(imageFingerPoint)
                    guard let hitTestResult = hitTestResults.first else { return }
                    guard let node = hitTestResults.first?.node,
                          let bubble = node.parent as? Bubble,
                          let hitResult = hitTestResults.first else {
                          return
                    }
                    
                   
                    bubble.pop()

                    
                }
            }

            guard let outBuffer = outputBuffer else {
                return
            }

            // Create UIImage from CVPixelBuffer
            previewImage = UIImage(ciImage: CIImage(cvPixelBuffer: outBuffer))

            normalizedFingerTip = outBuffer.searchTopPoint()
           
        }
        
        
    }
    
    
    
    func initializeBubblesTap( onView view: UIView){
        
        spawnedBubbles = false
        bubbleScheduler = nil
        
    }
    
    
    func addBubbles( on node: SCNNode){
        
       bubbleScheduler = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true, block: { (Timer) in
           
                for _ in 0...10{
                    
                    let randomX = Float.random(in: -0.5...0.5)
                    let randomY = Float.random(in: -0.5...0.5)
                    let randomZ = Float.random(in: -0.5...0.5)
                    
                    let bubbleNode = Bubble()
                    node.addChildNode(bubbleNode)
                    bubbleNode.position = SCNVector3( x: randomX, y: randomY, z: randomZ)

                }

            
        })
   
    }
    
}
