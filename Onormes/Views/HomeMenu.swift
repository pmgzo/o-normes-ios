//
//  HomeMenu.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 30/10/2021.
//


import Foundation
import SwiftUI

struct LogoMenuImage: View {
  var body: some View {
    Image("Logo")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 260)
  }
}

func getCurrentDay() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d"
    let dayString = dateFormatter.string(from: date)
    return dayString
}

let frenchMonths = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre"
]

func getCurrentMonth() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M"
    let monthIndex = Int(dateFormatter.string(from: date))!
    return frenchMonths[monthIndex - 1]
}

func getCurrentYear() -> String{
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY"
    let yearString = dateFormatter.string(from: date)
    return yearString
}



/**
This structure render the home page. From this page we can access to the user journey.

This is here where the **UJCoordinator** is created, before starting the user journey.

**Properties**:
- coordinator: user journey handler
- isShowingDetailView: variable used to trigger the user journey 's **NavigationLink** button

*/

struct HomeMenu: View {
  
    @State private var hasStartUserJouney = false
    @State private var hasOpenedTheFeedbackPage = false
    @State private var hasOpenedNotSentAudit = false

    @ObservedObject var coordinator: UJCoordinator;
    @EnvironmentObject var appState: AppState
    @StateObject private var userVM = UserViewModel()

    init() {
      self.coordinator = UJCoordinator()
    }
  
  var body: some View {
      return NavigationView {
          VStack {
              
              if appState.offlineModeActivated == false {
                  Text("Bonjour \(userVM.user?.first_name ?? "")").font(.system(size: 25))
                      .fontWeight(.semibold)
                      .foregroundColor(Color(hex: "29245A"))
                      .multilineTextAlignment(.center).onAppear(perform: {
                      userVM.getCurrentUser()
                  })
                  
                  Spacer().frame(height: 40)
                  
                  Text("Nous sommes le \(getCurrentDay()) \(getCurrentMonth()) \(getCurrentYear())") .foregroundColor(Color(hex: "29245A"))
                      .multilineTextAlignment(.center)
                  Text("Passez une bonne journée") .foregroundColor(Color(hex: "29245A"))
                      .multilineTextAlignment(.center)

                  
              } else {
                  Text("Mode offline").modifier(Header2(alignment: .center))
              }
              
              LogoMenuImage()
              
              NavigationLink(
                  destination: CreateAuditView().navigationBarHidden(true),
                  isActive: $hasStartUserJouney,
                  label: {
                      Button("Réaliser un diagnostic") {
                          hasStartUserJouney = true
                      }.modifier(PrimaryButtonStyle1(size: 300))
                  }
              )
              
              NavigationLink(
                destination:  SavedAudit().navigationBarHidden(true),
                  isActive: $hasOpenedNotSentAudit,
                  label: {
                      Button("Audits sauvegardés") {
                          hasOpenedNotSentAudit = true
                      }.modifier(SecondaryButtonStyle1(size: 300))
                  }
              )
              
              NavigationLink(
                  destination: FeedbackView(),
                  isActive: $hasOpenedTheFeedbackPage,
                  label: {
                      Button("Donner un feedback") {
                          hasOpenedTheFeedbackPage = true
                      }.modifier(SecondaryButtonStyle1(size: 300))
                  }
              )
              
              Spacer()
          }
      }
  }
};

struct HomeMenu_Previews: PreviewProvider {
    @StateObject var appState = AppState()
    
    static var previews: some View {
      Group {
          HomeMenu()
      }
    }
}
