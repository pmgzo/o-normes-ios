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
    
    @State var companyName: String = ""
    @State var address: String = ""
    @State var numberCompany: String = ""
    //@State var image: AsyncImage? = nil
    @State var imagePath: String?;

    var body: some View {
        if appState.offlineModeActivated == false {
            NavigationView {
              Form {
                  if userVM.user?.logo != nil && userVM.user?.logo != "" {
                      AsyncImage(url: URL(string: (userVM.user?.logo!)!)) { image in
                          image.resizable()
                              .clipped()
                              .frame(width: 100, height: 100, alignment: .center)
                              .clipShape(Circle())
                      } placeholder: {
                          ProgressView()
                      }
                      .frame(width: 100, height: 100)
                  } else {
                      Image("ProfileImage")
                        .resizable()
                        .clipped()
                        .frame(width: 100, height: 100, alignment: .center)
                        .clipShape(Circle())
                  }
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
                    Text(companyName)
                  }
                  HStack {
                    Text("Numéro de contact")
                    Spacer()
                    Text(numberCompany)
                  }
                  HStack {
                    Text("Adresse")
                    Spacer(minLength: 100)
                    Text(address)
                  }
                }
                  
              }.navigationBarTitle(Text("Profile"))
                
                
            }.onAppear(perform: {
                userVM.getCurrentUser()
                Task {
                    do {
                        let obj = try await APIService().getCompany()
                        companyName = obj["name"] as! String
                        address = obj["address"] as! String

                        numberCompany = obj["phone_number"] as! String
                        
                        
                        if obj["logo"] != nil {
                            imagePath = obj["logo"]! as? String
                        }

                    } catch {
                        print(error)
                        // mute error
                    }
                }
                
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
