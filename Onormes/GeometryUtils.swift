//
//  GeometryUtils.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 13/12/2021.
//

import Foundation
import ARKit

class GeometryUtils {
  static func calculateDistance(first: SCNVector3, second: SCNVector3) -> Float {
    var distance:Float = sqrt(
      pow(second.x - first.x, 2) +
      pow(second.y - first.y, 2) +
      pow(second.z - first.z, 2)
    )
    
    distance *= 100 // convert in cm
    return abs(distance)
  }
  
  static func calculateDistance(firstNode: SCNNode, secondNode:SCNNode) -> Float {
    return calculateDistance(first: firstNode.position, second: secondNode.position)
  }
  
  static func createCircle(fromRaycastResult result:ARRaycastResult) -> SCNNode {
    let circleGeometry = SCNSphere(radius: 0.010)
    
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.systemBlue
    
    circleGeometry.materials = [material]
    
    let circleNode = SCNNode(geometry: circleGeometry)
    circleNode.simdWorldTransform = result.worldTransform
    
    return circleNode
  }
}
