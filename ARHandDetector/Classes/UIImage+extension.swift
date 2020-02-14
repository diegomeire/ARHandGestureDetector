//
//  UIImage+extension.swift
//  ARHandDetector
//
//  Created by Diego Meire on 13/02/20.
//  Copyright © 2020 Diego Meire. All rights reserved.
//
import Foundation
import UIKit

extension UIImage {
    
    public convenience init?(with name: String, bundle: Bundle) {
        self.init(named: name, in: bundle, compatibleWith: nil)
    }
    
    public convenience init?(with name: String) {
        self.init(with: name, bundle: Bundle.main)
    }
}
