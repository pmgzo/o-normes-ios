//
//  SceneView.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 14/01/2022.
//

import SwiftUI

struct SceneView: View {
  private var loginVM = ViewController()

    var body: some View {
      loginVM()
    }
}

struct SceneView_Previews: PreviewProvider {
    static var previews: some View {
        SceneView()
    }
}
