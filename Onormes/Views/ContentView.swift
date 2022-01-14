  //
  //  ContentView.swift
  //  Onormes
  //
  //  Created by Toufik Belgacemi on 30/10/2021.
  //

  import SwiftUI

  struct ContentView: View {
    @ObservedObject var arDelegate = ARDelegate()
  
        var body: some View {
        VStack(alignment: .center, content: {
          TabView {
            ARViewRepresentable(arDelegate: arDelegate)
              .tabItem {
                Image(systemName: "ruler.fill")
                Text("Mesures")
              }
            
            ReconsView()
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

  struct ContentView_Previews: PreviewProvider {
      static var previews: some View {
        Group {
          ContentView()
            .preferredColorScheme(.dark)
        }
      }
  }
