//
//  ViewController.swift
//  ARHandDetector
//
//  Created by Diego Meire on 10/02/20.
//  Copyright © 2020 Diego Meire. All rights reserved.
//

import UIKit
import ARKit
import CoreML
import Vision

class UIGestureViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var button: UIButton!
    
    var previewView = UIImageView()
    
    var currentBuffer: CVPixelBuffer?
    
    var cursorView: CursorView?
   
    var holdingHandsCounter: Int = 0
    
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
        
        
        cursorView = CursorView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
       
        view.addSubview(cursorView!)
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

                    self.cursorView?.isHidden = true
                    
                    guard let tipPoint = normalizedFingerTip else {
                        self.button.backgroundColor = .clear
                        self.button.setTitleColor(.white, for: .normal)
                        return
                    }

                    // We use a coreVideo function to get the image coordinate from the normalized point
                    let imageFingerPoint = VNImagePointForNormalizedPoint(tipPoint, Int(self.view.bounds.size.width), Int(self.view.bounds.size.height))

                    self.cursorView?.frame.origin = CGPoint(x: imageFingerPoint.x - ( (self.cursorView?.frame.width)! / 2 ),
                                                              y: imageFingerPoint.y - ( (self.cursorView?.frame.height)! / 2 ))
                    
                    let scenePoint = self.sceneView.unprojectPoint(SCNVector3(imageFingerPoint.x, imageFingerPoint.y, 0))
                    
                    
                    self.cursorView?.isHidden = false
                    
                    if ((self.cursorView?.overlaps(other: self.button, in: self))!){
                        
                        self.alpha = self.alpha + 0.1
                        
                        self.button.backgroundColor = UIColor( red: 1, green: 1, blue: 1, alpha: self.alpha)
                        self.button.setTitleColor(.black, for: .normal)
                        if (self.alpha >= 1.0){
                            self.button.backgroundColor = .black
                            self.button.setTitleColor(.white, for: .normal)
                            
                            self.showAlert("Button pressed!")
                        }
                    }
                    else{
                        self.button.backgroundColor = .clear
                        self.button.tintColor = .white
                        self.alpha = 0
                    }
                    
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
