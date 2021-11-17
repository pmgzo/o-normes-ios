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
          LogoImage()
          Text("Vous êtes connecté !")
        }).background(Color.white).padding()
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
