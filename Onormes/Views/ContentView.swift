  //
  //  ContentView.swift
  //  Onormes
  //
  //  Created by Toufik Belgacemi on 30/10/2021.
  //

  import SwiftUI

  struct ContentView: View {
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
            
            Text("Vous êtes connecté !")
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
        })
        .preferredColorScheme(.light)
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

  struct ContentView_Previews: PreviewProvider {
      static var previews: some View {
        Group {
          ContentView()
            .preferredColorScheme(.dark)
        }
      }
  }
