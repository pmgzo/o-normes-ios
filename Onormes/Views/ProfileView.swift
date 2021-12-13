//
//  ProfileView.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 13/12/2021.
//

import SwiftUI

struct ProfileView: View {
  let gradient = Gradient(colors: [.blue, .orange])
  @State private var enableBlogger = true

    var body: some View {
      NavigationView {
        Form {
          Image("ProfileImage")
            .resizable()
            .clipped()
            .frame(width: 100, height: 100, alignment: .center)
            .clipShape(Circle())
          Section(header: Text("informations personnelles")) {
            HStack {
              Text("First Name")
              Spacer(minLength: 100)
              Text("Anmol")
            }
            HStack {
              Text("Last Name")
              Spacer(minLength: 100)
              Text("Maheshwari")
            }
            HStack {
              Text("Email")
              Spacer()
              Text("Maheshwari@gmail.com")
            }
            HStack {
              Text("Numéro de téléphone")
              Spacer()
              Text("06 12 34 56 78")
            }
          }
          Section(header: Text("Informations entreprise")) {
            HStack {
              Text("Nom")
              Spacer(minLength: 100)
              Text("N/A")
            }
            HStack {
              Text("Numéro de contact")
              Spacer(minLength: 100)
              Text("N/A")
            }
            HStack {
              Text("Adresse")
              Spacer(minLength: 100)
              Text("N/A")
            }
          }
        }.navigationBarTitle(Text("Profile"))
      }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
