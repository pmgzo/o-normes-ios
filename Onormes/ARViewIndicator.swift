//
//  NavigationIndicator.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 14/01/2022.
//

import Foundation
import ARKit
import SwiftUI

struct ARViewIndicator: UIViewControllerRepresentable {
  typealias UIViewControllerType = ViewController
  func makeUIViewController(context: Context) -> ViewController {
    return ViewController()
  }
  func updateUIViewController(_ uiViewController:
                              ARViewIndicator.UIViewControllerType, context:
                              UIViewControllerRepresentableContext<ARViewIndicator>) { }
}
