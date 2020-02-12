//
//  UIView+extension.swift
//  ARHandDetector
//
//  Created by Diego Meire on 11/02/20.
//  Copyright © 2020 Diego Meire. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func overlaps(other view: UIView, in viewController: UIViewController) -> Bool {
        let frame = self.convert(self.bounds, to: viewController.view)
        let otherFrame = view.convert(view.bounds, to: viewController.view)
        return frame.intersects(otherFrame)
    }
}
