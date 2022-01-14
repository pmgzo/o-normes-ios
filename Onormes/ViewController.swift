//
//  ViewController.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 12/01/2022.
//

import Foundation
import ARKit
import RealityKit
import SwiftUI

struct ViewControllerRecons: UIViewRepresentable {
  func makeUIView(context: Context) -> some UIView {
    let arView = ARView(frame: .zero)
    arView.automaticallyConfigureSession = false
    let config = ARWorldTrackingConfiguration()
    config.sceneReconstruction = .meshWithClassification
    arView.debugOptions.insert(.showSceneUnderstanding)
    arView.session.run(config, options: [])
    return arView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
 

}
