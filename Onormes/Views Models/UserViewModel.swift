//
//  UserViewModel.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 15/12/2021.
//

import Foundation

/**
    This is class is for retrieving the user data, used in Profile page
 
 */

class UserViewModel: ObservableObject {
  @Published var user: User?
  
/**
    This function returns us the cached result of the query **getUser**.
    It enables to get the user's data used in the **Profile** page.
 */
    
  func getCurrentUser() {
    APIService().getUser() { (result) in
      DispatchQueue.main.async {
        self.user = result
      }
    }
  }
}
