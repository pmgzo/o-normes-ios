//
//  NavigationBar.swift
//  Onormes
//
//  Created by gonzalo on 09/09/2022.
//

import SwiftUI

/**

This class handles the bar navigation view, redirect the user according to what he has clicked

*/

struct NavigationBarView: View {
      var body: some View {
          VStack(alignment: .center, content: {
              TabView {
                MeasuresVCRepresented()
                  .tabItem {
                    Image(systemName: "ruler.fill")
                    Text("Mesures")
                  }
                
                ReconstructionVCRepresented()
                  .tabItem {
                    Image(systemName: "sensor.tag.radiowaves.forward.fill")
                    Text("LiDAR")
                  }
                
                  HomeMenu()
                  .tabItem {
                    Image(systemName: "house")
                    Text("Accueil")
                  }
                
                ProfileView()
                  .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profil")
                  }
              }.accentColor(Color(hex: 0x282359))
          }).preferredColorScheme(.light).navigationBarHidden(true)

      }
}

struct ReconstructionVCRepresented : UIViewControllerRepresentable {
func updateUIViewController(_ uiViewController: ReconstructionViewController, context: Context) {
    
}

func makeUIViewController(context: Context) -> ReconstructionViewController {
  UIStoryboard(name: "Reconstruction", bundle: Bundle.main).instantiateViewController(identifier: "ReconstructionViewController") as! ReconstructionViewController
}
}

struct MeasuresVCRepresented : UIViewControllerRepresentable {
func updateUIViewController(_ uiViewController: AreaViewController, context: Context) {
}

func makeUIViewController(context: Context) -> AreaViewController {
  UIStoryboard(name: "Measure", bundle: Bundle.main).instantiateViewController(identifier: "AreaViewController") as! AreaViewController
}
}
