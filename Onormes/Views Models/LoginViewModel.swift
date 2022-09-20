//
//  LoginViewModel.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 06/11/2021.
//

import Foundation

/**
    This class handle the data entered within the login forms and send it to then backend to get the user authentified
 
 */

class LoginViewModel: ObservableObject {
    @Published var credentials = Credentials()
    @Published var showProgressView = false
    @Published var isAuthenticate: Bool = false
    @Published var error: Authentication.AuthenticationError?

    init() {
//        credentials.email = "thomas-dong@epitech.eu"
//        credentials.password = "toto"
    }
    
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
              print("la")
              APIService().updateCriteriaList()
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
