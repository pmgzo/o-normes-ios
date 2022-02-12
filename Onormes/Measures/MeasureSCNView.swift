//
//  MeasuresSCNView.swift
//  O-NormesV2
//
//  Created by Toufik Belgacemi on 11/02/2022.
//

import UIKit
import ARKit

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
  
  func run() {
    self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
  }
  
  func pause() {
    self.session.pause()
  }
  
  func distance(betweenPoints point1: SCNVector3, point2: SCNVector3) -> CGFloat {
    let dx = point2.x - point1.x
    let dy = point2.y - point1.y
    let dz = point2.z - point1.z
    return CGFloat(sqrt(dx*dx + dy*dy + dz*dz))
  }
  
}
