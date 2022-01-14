//
//  NavigatorIndicator.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 14/01/2022.
//

import Foundation
import SwiftUI

struct NavigationIndicator: UIViewControllerRepresentable {
  typealias UIViewControllerType = ViewController
  func makeUIViewController(context: Context) -> ViewController {
    return ViewController()
  }
  func updateUIViewController(_ uiViewController:
                              NavigationIndicator.UIViewControllerType, context:
                              UIViewControllerRepresentableContext<NavigationIndicator>) { }
}

struct ReconsView: View {
  @State var page = "Home"
  
  var body: some View {
    VStack {
        ZStack {
          NavigationIndicator()
      }
  }
}
}
