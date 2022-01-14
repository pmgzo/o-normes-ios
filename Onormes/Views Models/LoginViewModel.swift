//
//  LoginViewModel.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 06/11/2021.
//

import Foundation

class LoginViewModel: ObservableObject {
  @Published var credentials = Credentials()
  @Published var showProgressView = false
  @Published var isAuthenticate: Bool = false
  @Published var error: Authentication.AuthenticationError?


  var loginDisabled: Bool {
    credentials.email.isEmpty || credentials.password.isEmpty
  }
  
  func login(completion: @escaping (Bool) -> Void) {
    
    let defaults = UserDefaults.standard
    showProgressView = true

    APIService().login(credentials: credentials) { result in

      DispatchQueue.main.async {
        self.showProgressView = false
      }
      
      switch result {
        case .success(let token):
          defaults.set(token, forKey: "token")
          defaults.set(self.credentials.email, forKey: "email")
          DispatchQueue.main.async {
            self.isAuthenticate = true
          }
          completion(true)
        case .failure(let error):
          DispatchQueue.main.async {
            self.error = error
          }
          completion(false)
      }

    }
    
  }

}
