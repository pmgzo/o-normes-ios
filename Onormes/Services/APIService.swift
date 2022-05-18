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
    guard let url = URL(string: "http://212.25.139.196:3001/api/users/connect") else {
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
  
    func getUser(completion: @escaping (User) -> Void) {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""

        guard let url = URL(string: "http://212.25.137.55:3001/api/users/?email=\(email)") else { return }
        
        // Build the request, set the method, the value and the body of the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) {(data, response, error) in
          guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
          }

          guard let userResponse = try? JSONDecoder().decode(User.self, from: data) else {
            print("Error get current User")
            return
          }
          completion(userResponse)
        }.resume()
    }
    
    // TODO: Add parameters in body, have to return the audit id
    func createAudit(name: String, location: String, comment: String, owner_phone: String, owner_email: String) -> String {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""
        
        guard let url = URL(string: "http://212.25.137.55:3001/api/audit/?email=\(email)") else { return "error mail" }
        
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // fill the body
        let json: [String: Any] = ["name": name, "place": location, "global_comment": comment, "place_owner_phone": owner_phone, "place_owner_mail": owner_email]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) {(data, response, error) in
          guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
          }

          guard let userResponse = try? JSONDecoder().decode(User.self, from: data) else {
            print("Error audit not created")
            return
          }
          //completion(userResponse)
        }.resume()
        // return body
        
        return ""
    }

    func createMeasure(params: NSDictionary) {
        // more info here: http://51.103.72.63:3001/api-docs/#/Measure/post_api_measure_
        // audit_fk
        // norm_fk not used
        // metric Fk (see aurele's message)

        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""
        
        guard let url = URL(string: "http://212.25.137.55:3001/api/measure/?email=\(email)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        //fill body
        let json: [String: Any] = [
            "metric_fk": 0,
            "audit_fk": params["audit_fk"],
            "norme_fk": "string",
            "kitName": params["kitName"],
            "name": params["name"],
            "value": params["value"],
            "photo": "pas de photo",
            "comment": params["comment"],
            "detail": params["details"],
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) {(data, response, error) in
          guard let data = data, error == nil else {
            print(error?.localizedDescription ?? "No data")
            return
          }

          guard let userResponse = try? JSONDecoder().decode(User.self, from: data) else {
            print("Error measure not created")
            return
          }
          //completion(userResponse)
        }.resume()
    }

 }

func sendAllDataAudit(auditId: String, data: [DataNorm]) -> Bool {
    for norm in data {
        for regulation in norm.data {
            var value = regulation.valueMetric
            if regulation.type == TypeField.bool {
                value = regulation.valueCheckBox == true ? "True" : "False"
            }
            APIService().createMeasure(params: ["audit_fk": auditId, "kitName": "", "name": regulation.key, "value": value, "comment": regulation.comment, "details": regulation.instruction])
        }
        print("norm " + norm.key + " done.")
    }
    
    return true
}
