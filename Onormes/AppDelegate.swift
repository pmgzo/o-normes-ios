//
//  AppDelegate.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 12/01/2022.
//

import Foundation
import ARKit
import RealityKit

class AppDelegate: NSObject, UIViewController, ObservableObject {
  func setARView(_ arView: ARSCNView) {
    self.arView = arView
    
    arView.automaticallyConfigureSession = false
    let config = ARWorldTrackingConfiguration()
    config.sceneReconstruction = .meshWithClassification
    arView.debugOptions.insert(.showSceneUnderstanding)
    arView.session.run(config, options: [])
  }

  private var arView: ARSCNView?
}

