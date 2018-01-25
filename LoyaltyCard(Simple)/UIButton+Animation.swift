//
//  UIButton+Animation.swift
//  7Leaves Card
//
//  Created by John Nik on 2/23/17.
//  Copyright © 2016 johnik703. All rights reserved.
//

import Foundation
import UIKit


extension UIButton {
    
    // Functions for animation buttons regarding compressing and decompressing (bouncing/zoom animation).
    
    func playImplicitBounceAnimation() {
        
        let bounceAnimation             = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values          = [1.0 ,1.4, 0.9, 1.15, 0.95, 1.02, 1.0]
        bounceAnimation.duration        = TimeInterval(0.5)
        bounceAnimation.calculationMode = kCAAnimationCubic
        
        layer.add(bounceAnimation, forKey: "bounceAnimation")
    }
    
    func playExplicitBounceAnimation() {
        DispatchQueue.main.async {
            var values = [Double]()
            let e = 2.71
            
            for t in 1..<100 {
                let value = 0.6 * pow(e, -0.045 * Double(t)) * cos(0.1 * Double(t)) + 1.0
                values.append(value)
            }
            
            let bounceAnimation             = CAKeyframeAnimation(keyPath: "transform.scale")
            bounceAnimation.values          = values
            bounceAnimation.duration        = TimeInterval(0.275)
            bounceAnimation.calculationMode = kCAAnimationCubic
            
            self.layer.add(bounceAnimation, forKey: "bounceAnimation")
        }
    }
    
    func setDefaultImage(name: String) {
        self.setImage(UIImage(named: name), for: .normal)
    }
    
    func setSelectedImage(name: String) {
        self.setImage(UIImage(named: name), for: .selected)
    }
}
