//
//  Bubble.swift
//  ARKitFaceExample
//
//  Created by Diego Meire on 02/12/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import Foundation
import SceneKit

class Bubble: SCNNode {
    
    
    var bubbleNode : SCNNode?
    
    override init() {
        
        let randomSize = CGFloat.random(in: 0.01...0.05)
        let bubbleGeometry = SCNPlane(width: randomSize, height: randomSize)
        bubbleNode = SCNNode( geometry: bubbleGeometry)
        
        let bubbleMaterial = SCNMaterial()
        bubbleMaterial.lightingModel = .constant
        bubbleMaterial.diffuse.contents = UIImage(with: "art.scnassets/bubble.png")
        bubbleMaterial.blendMode = .add
        
        
        bubbleNode!.geometry!.materials = [bubbleMaterial]
        let constraint = SCNBillboardConstraint()
        constraint.freeAxes = [ SCNBillboardAxis.all ]
        bubbleNode!.constraints = [constraint]
        bubbleNode!.renderingOrder = 1
        
        super.init()
        
        self.addChildNode(bubbleNode!)
        
           
        bubbleNode!.runAction(SCNAction.scale(to: 0, duration: 0))
        bubbleNode!.runAction(SCNAction.repeatForever(
                                SCNAction.group([ SCNAction.scale(to: 1,
                                                                  duration: 0.1),
                                                  SCNAction.move(by: SCNVector3(0, 0.5, 0),
                                                                 duration: TimeInterval.random(in: 10...20)),
                                                  SCNAction.sequence([
                                                        SCNAction.wait(duration: 5),
                                                        SCNAction.run({ (node) in
                                                                self.bubbleNode?.removeFromParentNode()
                                                                self.bubbleNode = nil
                                                        })
                                                ])
                                        ])
                                )
                            )
     
    }
    
    deinit {
        bubbleNode?.removeAllActions()
        bubbleNode?.removeFromParentNode()
        bubbleNode = nil
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    

    
}
