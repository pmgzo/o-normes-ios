//
//  HomeMenu.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 30/10/2021.
//


import Foundation
import SwiftUI

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
  
      init() {
          self.coordinator = UJCoordinator()
      }
  
  var body: some View {
      return NavigationView {
          VStack {
              
              if appState.offlineModeActivated == false {
                  Text("Vous êtes connecté !")
              }
              else {
                  Text("Mode offline")
              }
              
//              CustomNavigationLink(coordinator: coordinator, isActive: $hasStartUserJouney, destination: { () -> GenericRegulationView in
//                  return self.coordinator.getNextView()
//              },label: {
//                  Button("Réaliser un diagnostique d'accessibilité") {
//                      self.coordinator.nextStep(start: true)
//                      hasStartUserJouney = true
//                  }.buttonStyle(ButtonStyle())
//              })
              
              NavigationLink(
                  destination: CreateAuditView().navigationBarHidden(true),
                  isActive: $hasStartUserJouney,
                  label: {
                      Button("Réaliser un diagnostic") {
                          hasStartUserJouney = true
                      }.buttonStyle(ButtonStyle())
                  }
              )
              
              NavigationLink(
                  destination: FeedbackView(),
                  isActive: $hasOpenedTheFeedbackPage,
                  label: {
                      Button("Donner un feedback") {
                          hasOpenedTheFeedbackPage = true
                      }.buttonStyle(ButtonStyle())
                  }
              )
              
              NavigationLink(
                  destination: SavedAudit(),
                  isActive: $hasOpenedNotSentAudit,
                  label: {
                      Button("Audits sauvegardés") {
                          hasOpenedNotSentAudit = true
                      }.buttonStyle(ButtonStyle())
                  }
              )
          }
      }
  }
};

struct HomeMenu_Previews: PreviewProvider {
    static var previews: some View {
      Group {
          HomeMenu()
      }
    }
}
