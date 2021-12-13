//
//  ARViewRepresentable.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 13/12/2021.
//

import ARKit
import SwiftUI

struct ARViewRepresentable: UIViewRepresentable {
  let arDelegate:ARDelegate
  
  func makeUIView(context: Context) -> some UIView {
    let arView = ARSCNView(frame: .zero)
    arDelegate.setARView(arView)
    return arView
  }
  
  func updateUIView(_ uiView: UIViewType, context: Context) {
    
  }
}

struct ARViewRepresentable_Previews: PreviewProvider {
  static var previews: some View {
    ARViewRepresentable(arDelegate: ARDelegate())
  }
}
