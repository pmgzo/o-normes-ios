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
//            DropDownMenu(labelList: ["Yaourt", "fromage", "chaussure", "4", "8", "9", "10", "11", "13", "664"])
          if authentication.isValidated {
              NavigationBarView()
              .environmentObject(authentication)
          } else {
            LoginView()
              .environmentObject(authentication)
          }
        }
    }
}
