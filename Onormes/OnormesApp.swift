//
//  OnormesApp.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 30/10/2021.
//

import SwiftUI

@main
struct OnormesApp: App {
    @StateObject var authentication = Authentication()
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
          if authentication.isValidated {
              NavigationBarView()
              .environmentObject(authentication)
              .environmentObject(appState)
          } else {
            LoginView()
              .environmentObject(authentication)
              .environmentObject(appState)
          }
        }
    }
}
