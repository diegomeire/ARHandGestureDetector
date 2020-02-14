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
        
        let randomSize = CGFloat.random(in: 0.1...0.2)
        
        let bubbleScene = SCNScene(named: "art.scnassets/bubble.scn")
        bubbleNode = bubbleScene?.rootNode.childNodes[0]
        
        super.init()
        
        self.addChildNode(bubbleNode!)
        bubbleNode?.scale = SCNVector3(0.001, 0.001, 0.001)
        bubbleNode!.renderingOrder = 1
        
       // particles!.birthRate = 0
           
        bubbleNode!.runAction(SCNAction.scale(to: 0, duration: 0))
        bubbleNode!.runAction(SCNAction.repeatForever(
                                SCNAction.group([ SCNAction.scale(to: randomSize,
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
    
    func pop(){
        bubbleNode!.geometry?.firstMaterial?.diffuse.contents = UIImage( with: "art.scnassets/bubblePop.png")
        bubbleNode!.runAction(SCNAction.scale(to: CGFloat((bubbleNode?.scale.x)! * Float(1.2)),
                                              duration: 0.5))
        
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (Timer) in
            self.bubbleNode?.removeAllActions()
            self.bubbleNode?.removeFromParentNode()
            self.bubbleNode = nil
        }
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
