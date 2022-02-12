//
//  SCNSphere+Init.swift
//  O-NormesV2
//
//  Created by Toufik Belgacemi on 11/02/2022.
//

import Foundation
import SceneKit

extension SCNSphere {
  convenience init(color: UIColor, radius: CGFloat) {
    self.init(radius: radius)
    
    let material = SCNMaterial()
    materials = [material]
  }
}
