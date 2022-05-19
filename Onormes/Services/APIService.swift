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

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

class APIService {  
  func login(credentials: Credentials, completion: @escaping (Result<String, Authentication.AuthenticationError>) -> Void) {

    // Check the URL, if the URL isn't correctly formated return an error
    guard let url = URL(string: "http://51.103.72.63:3001/api/users/login") else {
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
      guard let loginResponse = try? JSONDecoder().decode(String.self, from: data) else {
        completion(.failure(.invalidCredentials))
        return
      }

      // Return the token
      completion(.success(loginResponse))
      
    }.resume()
  }
  
    func getUser(completion: @escaping (User) -> Void) {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""

        guard let url = URL(string: "http://51.103.72.63:3001/api/users/?email=\(email)") else { return }
        
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
    func createAudit(name: String, location: String, comment: String, owner_phone: String, owner_email: String) async -> String {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""
        
        guard let url = URL(string: "http://51.103.72.63:3001/api/audit/?email=\(email)") else { return "error mail" }
        
        var request = URLRequest(url: url)
        var auditId: String = ""

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // fill the body
        let json: [String: Any] = ["name": name[0..<20], "place": location, "global_comment": comment, "place_owner_phone": owner_phone, "place_owner_mail": owner_email]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            print(data)
            let string: String = String(data: data, encoding: .utf8)!

            print("data")
            print(data)
            
            let dic = convertToDictionary(text: string)
            
            print(dic)
            
            auditId = String(dic!["id"]! as! Int)
            return auditId
        } catch {
            print(error)
        }
                
//
//        let dataTask = URLSession.shared.dataTask(with: request) {(data, response, error) in
//          guard let data = data, error == nil else {
//            print(error?.localizedDescription ?? "No data")
//            return
//          }
//
//            print(response)
//            print(data)
//            let string: String = String(data: data, encoding: .utf8)!
//
//            print("data")
//            print(data)
//
//            let dic = convertToDictionary(text: string)
//
//            auditId = String(dic!["id"]! as! Int)
//
//
//          guard let userResponse = try? JSONDecoder().decode(User.self, from: data) else {
//            print("Error audit not created")
//            return
//          }
//          //completion(userResponse)
//        }
        
        //dataTask.resume()
        // return body
        print("auditId")
        print(auditId)
        
        return auditId
    }

    func createMeasure(params: NSDictionary) {
        // more info here: http://51.103.72.63:3001/api-docs/#/Measure/post_api_measure_
        // audit_fk
        // norm_fk not used
        // metric Fk (see aurele's message)

        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""
        
        guard let url = URL(string: "http://51.103.72.63:3001/api/measure/?email=\(email)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        print("audit_fk")
        print(params["audit_fk"])
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
    print("send audit id")
    print(auditId)
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
