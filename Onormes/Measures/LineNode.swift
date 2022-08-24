//
//  LineNode.swift
//  O-NormesV2
//
//  Created by Toufik Belgacemi on 11/02/2022.
//

import UIKit
import SceneKit

/**
 
 This the line vector component rendered in the measure view, once we select two points.
 
**Construtor**:
 ```swift
 init(from vectorA: SCNVector3, to vectorB: SCNVector3, lineColor color: UIColor, lineWidth width: CGFloat)
 ```
**Parameters**:
    - vectorA: first point selected, component in the AR Scene
    - vectorB: second point selected, component in the AR Scene
    - lineColor:  color of the line, with respect to the **UIColor** structure
    - lineWidth: width of the line
 
 */

class LineNode: SCNNode {
  
  let lineThickness = CGFloat(0.001)
  let radius = CGFloat(0.1)
  private var boxGeometry: SCNBox!
  private var nodeLine: SCNNode!
  
  init(from vectorA: SCNVector3, to vectorB: SCNVector3, lineColor color: UIColor, lineWidth width: CGFloat) {
    super.init()
    
    self.position = vectorA
    
    let nodeZAlign = SCNNode()
    nodeZAlign.eulerAngles.x = Float.pi/2
    
    let height = self.distance(from: vectorA, to: vectorB)
    boxGeometry = SCNBox(width: width, height: height, length: lineThickness, chamferRadius: radius)
    let material = SCNMaterial()
    boxGeometry.materials = [material]
    
    let nodeLine = SCNNode(geometry: boxGeometry)
    nodeLine.position.y = Float(-height/2) + 0.001
    nodeZAlign.addChildNode(nodeLine)
    
    self.addChildNode(nodeZAlign)
    
    let orientationNode = SCNNode()
    orientationNode.position = vectorB
    self.constraints = [SCNLookAtConstraint(target: orientationNode)]
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
    
    /**
     Function to calculate distance between two physical point in the AR scene.
    - Parameters:
    - vectorA: first point component
    - vectorB:  second point component
     - Returns: the distance between two points
*/
  
  func distance(from vectorA: SCNVector3, to vectorB: SCNVector3)-> CGFloat {
    return(CGFloat(sqrt(
      (vectorA.x - vectorB.x) * (vectorA.x - vectorB.x) +
      (vectorA.y - vectorB.y) * (vectorA.y - vectorB.y) +
      (vectorA.z - vectorB.z) * (vectorA.z - vectorB.z))))
  }
  
  func updateNode(vectorA: SCNVector3? = nil, vectorB: SCNVector3? = nil, color: UIColor?) {
    if let vectorA = vectorA, let vectorB = vectorB {
      
      let height = self.distance(from: vectorA, to: vectorB)
      boxGeometry.height = height
      let material = SCNMaterial()
      boxGeometry.materials = [material]
      
      let nodeZAlign = SCNNode()
      nodeZAlign.eulerAngles.x = Float.pi/2
      
      let nodeLine = SCNNode(geometry: boxGeometry)
      
      nodeLine.position.y = Float(-height/2) + 0.001
      nodeZAlign.addChildNode(nodeLine)
      
      self.addChildNode(nodeZAlign)
      
      let orientationNode = SCNNode()
      orientationNode.position = vectorB
      self.constraints = [SCNLookAtConstraint(target: orientationNode)]
    }
  }
}
