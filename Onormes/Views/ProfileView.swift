//
//  ProfileView.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 13/12/2021.
//

import SwiftUI

/**
 This structure renders the Profile page.
 
 **Properties**:
    - userVM: variable who the user info to display on the profile page
 
 */

struct ProfileView: View {
    @StateObject private var userVM = UserViewModel()
    @State private var hasOpenedTheFeedbackPage = false
    
    @EnvironmentObject var appState: AppState
  
    var body: some View {
        if appState.offlineModeActivated == false {
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
                    Text(userVM.user?.first_name ?? "")
                  }
                  HStack {
                    Text("Last Name")
                    Spacer(minLength: 100)
                    Text(userVM.user?.last_name ?? "")
                  }
                  HStack {
                    Text("Email")
                    Spacer()
                    Text(userVM.user?.email ?? "")
                  }
                  HStack {
                    Text("Numéro de téléphone")
                    Spacer()
                    Text(userVM.user?.phone_number ?? "")
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
                  NavigationLink(
                      destination: FeedbackView(),
                      isActive: $hasOpenedTheFeedbackPage,
                      label: {
                          Button("Donner un feedback") {
                              hasOpenedTheFeedbackPage = true
                          }.buttonStyle(ButtonStyle())
                      }
                  )
                  
                  
              }.navigationBarTitle(Text("Profile"))
                
                
            }.onAppear(perform: {
              userVM.getCurrentUser()
            })
        } else {
            Text("Mode offline")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
