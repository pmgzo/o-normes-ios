//
//  APIService.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 06/11/2021.
//

import Foundation

struct LoginResponse: Codable {
  let token: String?
  let message: String?
  let success: String?
}

class APIService {  
  func login(credentials: Credentials, completion: @escaping (Result<String, Authentication.AuthenticationError>) -> Void) {

    // Check the URL, if the URL isn't correctly formated return an error
    guard let url = URL(string: "http://localhost:3001/api/users/connect") else {
      completion(.failure(.custom(errorMessage: "Url is not correct")))
      return
    }

    // Create the body of the request with the credentials class
    let body = Credentials(email: credentials.email, password: credentials.password)

    // Build the request, set the method, the value and the body of the request
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONEncoder().encode(body)

    // Make the call API
    URLSession.shared.dataTask(with: request) { (data, response, error) in

      // If no data, throw an error
      guard let data = data, error == nil else {
        completion(.failure(.custom(errorMessage: "Serveur erreur")))
        return
      }

      // Get the data from the template class LoginReponse
      guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
        completion(.failure(.invalidCredentials))
        return
      }

      // If the data do not contain the token throw an error
      guard let token = loginResponse.token else {
        completion(.failure(.invalidCredentials))
        return
      }

      // Return the token
      completion(.success(token))
      
    }.resume()
    
  }
}
