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

    var body: some Scene {
        WindowGroup {
//          if authentication.isValidated {
            ContentView()
              .environmentObject(authentication)
//          } else {
//            LoginView()
//              .environmentObject(authentication)
//          }
        }
    }
}
