//
//  UIViewController+extension.swift
//  ARHandDetector
//
//  Created by Diego Meire on 13/02/20.
//  Copyright © 2020 Diego Meire. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
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
}
