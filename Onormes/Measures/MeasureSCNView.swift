//
//  MeasuresSCNView.swift
//  O-NormesV2
//
//  Created by Toufik Belgacemi on 11/02/2022.
//

import UIKit
import ARKit

/**
 
    Class used in the measure storyboard, to handle the **ARSCNView** (AR Scene)
 
    **Properties**:
    - configuration: AR configurations
    - markedPoints: points that will be render
 
 */

open class MeasureSCNView: ARSCNView {
  
  private var configuration = ARWorldTrackingConfiguration()
  var markedPoints = [SCNVector3]()
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setUp()
  }
  
  //MARK: - Private helper methods
  
  private func setUp() {
    let scene = SCNScene()
    
    self.automaticallyUpdatesLighting = true
    self.scene = scene
    configuration.planeDetection = [.horizontal]
  }
  
    /**
            Convert a CGPoint into a 3DVector (**SCNVector3**)
     
        - Returns: SCN3DVector to be rendered
     */
    
  func hitResult(forPoint point: CGPoint) -> SCNVector3? {
    let tapLocation: CGPoint = point
    let estimatedPlane: ARRaycastQuery.Target = .estimatedPlane
    let alignment: ARRaycastQuery.TargetAlignment = .any
    
    guard let query = self.raycastQuery(from: tapLocation,
                                        allowing: estimatedPlane,
                                        alignment: alignment) else { return nil }
    
    let hitTestResult = self.session.raycast(query)
    if let result = hitTestResult.first {
      let vector = result.worldTransform.columns.3
      return SCNVector3(vector.x, vector.y, vector.z)
    } else {
      return nil
    }
    
  }
  
  //MARK: - Public helper methods
  
    /**
            Function to run the scene, usally that fonction is used to restart the view
        
     */
    
  func run() {
    self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
  
    /**
            Function to pause the scene
     */
    
  func pause() {
    self.session.pause()
  }
    
    /**
        Fonction to compute distance between two points
     
        - Returns: return this between two points
     
     */
  
  func distance(betweenPoints point1: SCNVector3, point2: SCNVector3) -> CGFloat {
    let dx = point2.x - point1.x
    let dy = point2.y - point1.y
    let dz = point2.z - point1.z
    return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
  }
  
}
