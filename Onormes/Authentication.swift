//
//  Authentication.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 06/11/2021.
//

import SwiftUI

class Authentication: ObservableObject {
  @Published var isValidated = false
  
  enum AuthenticationError: Error, LocalizedError, Identifiable {
    case invalidCredentials
    case custom(errorMessage: String)
    
    var id: String {
      self.localizedDescription
    }
    
    var errorDescription: String? {
      switch self {
        case .invalidCredentials:
          return NSLocalizedString("Votre adresse email ou votre mot de passe sont incorrect.", comment: "")
        case .custom(let errorMessage):
          return NSLocalizedString(errorMessage, comment: "")
      }
    }
  }
  
  func updateValidation(success: Bool) {
    withAnimation {
      DispatchQueue.main.async {
        self.isValidated = success
      }
    }
  }
}
