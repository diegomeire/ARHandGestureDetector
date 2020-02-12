//
//  CursorView.swift
//  ARHandDetector
//
//  Created by Diego Meire on 11/02/20.
//  Copyright © 2020 Diego Meire. All rights reserved.
//

import Foundation
import UIKit

class CursorView: UIView {

    var circleLayer: CAShapeLayer?
    
    func setColor(_ color: UIColor){
        
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2),
                                             radius: CGFloat(20),
                                             startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)

        circleLayer?.removeFromSuperlayer()
        
        circleLayer = CAShapeLayer()
        circleLayer?.path = circlePath.cgPath
 
        //change the fill color
        circleLayer?.fillColor = color.cgColor
        //you can change the stroke color
        circleLayer?.strokeColor = color.cgColor
       
        layer.addSublayer(circleLayer!)
    }
    
    override init(frame: CGRect) {
        
           super.init(frame: frame)
           setColor(.red)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
