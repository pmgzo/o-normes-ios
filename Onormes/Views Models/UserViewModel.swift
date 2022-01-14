//
//  UserViewModel.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 15/12/2021.
//

import Foundation

class UserViewModel: ObservableObject {
  @Published var user: User?
  
  func getCurrentUser() {
    APIService().getUser() { (result) in
      DispatchQueue.main.async {
        self.user = result
      }
    }
  }
}
