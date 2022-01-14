//
//  SceneDelegate.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 14/01/2022.
//

import Foundation
import ARKit
import SwiftUI

struct SceneViewRepresentable: UIViewRepresentable {
  let sceneDelegate:AppDelegate
  
  func makeUIView(context: Context) -> some UIView {
    let arView = ARSCNView(frame: .zero)
    sceneDelegate.application(arView)
    return arView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {

  }
}

struct SceneViewRepresentable_Previews: PreviewProvider {
  static var previews: some View {
    Text("Hello, world!")
  }
}
