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

/**
 
 Enum for error handling for network request
 
 */

enum ServerErrorType: Error {
    case internalError(reason: String) // no data caught
}

class RequestError: LocalizedError {
    var errorDescription: String;
    var failureReason: String? = nil;
    var helpAnchor: String? = nil;
    var recoverySuggestion: String? = nil;

    init(errorDescription: String) {
        self.errorDescription = errorDescription
    }
}

/**
 
    Class to call backend api, each method is a dedicated request
 
 */

class APIService {
    
    /**
     
        Method to call the login route
        - Parameters:
            - credentials: user's credentials
            - completion: callback function to handle the request's response
     */
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
  
    /**
     
        Method to get user data
        - Parameters:
            - completion: callback function to handle the request's response
     
     */
    
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
    
    /**
     
        Return the user's company Id
     */
    
    func getCompanyId() async throws -> Int {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""

        guard let url = URL(string: "http://51.103.72.63:3001/api/companies/user") else { throw ServerErrorType.internalError(reason: "Echec de la création de la requête pour avoir l'id de la l'entreprise") }
        
        // Build the request, set the method, the value and the body of the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        var  id = 0
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ServerErrorType.internalError(reason: "Echec de l'obtention de l'id de la company")
        }
        
        let json = try? JSONSerialization.jsonObject(with: data, options: [])

        guard json != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }

        if let dictionary = json as? [String: Any] {
            id = dictionary["id"]! as! Int
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
        return id
    }
    
    /**
     
        Return the user's id
     */
    
    func getUserId() async throws -> Int {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""

        guard let url = URL(string: "http://51.103.72.63:3001/api/users/?email=\(email)") else {
            throw ServerErrorType.internalError(reason: "La construction de la requête pour obtenir l'id de l'utilisateur a échouée")
        }

        // Build the request, set the method, the value and the body of the request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        var  id = 0
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        guard json != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }
        
        if let dictionary = json as? [String: Any] {
            id = dictionary["id"]! as! Int
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
        return id
    }

    /**
     
        Method to create an audit
        - Parameters:
            - name: audit's id
            - location: audit's place
            - comment: comment
            - owner_phone: phone number
            - owner_email: email
        - Returns: the created audit's id (as confirmation)
     */
    
   func createAudit(auditInfos: AuditInfos) async throws -> Int {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        guard let url = URL(string: "http://51.103.72.63:3001/api/audit/") else { throw ServerErrorType.internalError(reason: "La construction de la requête pour créer l'audit a échouée")
        }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // fill the body
        let buildingId = buildingTypeList.firstIndex(where: {$0 == auditInfos.buildingType})! + 1
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        // get company's id : http://51.103.72.63:3001/api/companies/user
        // get user id:
        let userId = try await self.getUserId()
        let companyId = try await self.getCompanyId()
        
        let json: [String: Any] = [
            "name": auditInfos.name,
            "date": dateFormatter.string(from: auditInfos.date),
            "building_name": auditInfos.buildingName,
            "building_email": auditInfos.email,
            "building_phone": auditInfos.phoneNumber,
            "building_addr": auditInfos.address,
            "building_siret": auditInfos.siret,
            "owner_first_name": "",
            "owner_last_name": "",
            "owner_email": auditInfos.email,
            "owner_phone": auditInfos.phoneNumber,
            "comment": auditInfos.notes,
            "building_fk": buildingId,
            "company_fk": companyId,
            "auditeur_fk": userId
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)
       
       //print(String(decoding: data, as: UTF8.self))

        guard (response as? HTTPURLResponse)!.statusCode >= 200 && (response as? HTTPURLResponse)!.statusCode <= 299 else {
            throw ServerErrorType.internalError(reason: "La requête pour créer l'audit a échouée")
        }
        
        let receivedJson = try? JSONSerialization.jsonObject(with: data, options: [])

        guard receivedJson != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }
        
        if let dictionary = receivedJson as? [String: Any] {
            let id: Int = dictionary["id"]! as! Int
            return id
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
    }
    
    /**
     
        Create step, call in summary page when all the data is about to be saved.
            Return the step id
     */
    
    func createStep(stage: StageWrite, auditId: Int) async throws -> Int {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        guard let url = URL(string: "http://51.103.72.63:3001/api/step/") else { throw ServerErrorType.internalError(reason: "La construction de la requête pour créer l'étape a échouée") }
        var request = URLRequest(url: url)

        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        // fill the body
        let json: [String: Any] = [
            "name": stage.stageName,
            "description": stage.description,
            "area_fk": stage.idArea,
            "place_fk": stage.idPlace,
            "audit_fk": auditId,
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)!.statusCode >= 200 && (response as? HTTPURLResponse)!.statusCode <= 299 else {
            throw ServerErrorType.internalError(reason: "La création d'étape a échouée")
        }
        
        let receivedJson = try? JSONSerialization.jsonObject(with: data, options: [])
        
        guard receivedJson != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }
        
        if let dic = receivedJson as? [String:Any] {
            let id: Int = dic["id"]! as! Int
            return id
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
    }
    
    /**
     
        Build request and send the data
        - Parameters:
        - json: built json to put in the body
     */
    
    func createMeasureHelperFunction(json: [String:Any]) async throws -> Int {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        
        guard let url = URL(string: "http://51.103.72.63:3001/api/measure/") else {
            throw ServerErrorType.internalError(reason: "La construction de la requête pour créer une mesure a échouée")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        

        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)!.statusCode >= 200 && (response as? HTTPURLResponse)!.statusCode <= 299 else {
            throw ServerErrorType.internalError(reason: "La création de mesure a échouée")
        }
        
        let receivedJson = try? JSONSerialization.jsonObject(with: data, options: [])

        guard receivedJson != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }
        
        if let dic = receivedJson as? [String:Any] {
            let id: Int = dic["id"]! as! Int
            return id
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
    }
    
    /**
     
        Method to upload image, return the image's path
     - Parameters:
     - imagePath: path of Image registered in the phone
     - auditId:
     -
     
     */
    
    func uploadImage(filename: String, auditId: Int) async throws -> String {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        
        guard let url = URL(string: "http://51.103.72.63:3001/api/image") else {
            throw ServerErrorType.internalError(reason: "La construction de la requête pour créer une mesure a échouée")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let userId = try await self.getUserId()
        let companyId = try await self.getCompanyId()
        
        let base64EncodedImage = try? readImage(filename: filename)
        
        guard base64EncodedImage != nil else {
            throw ServerErrorType.internalError(reason: "La lecture de l'image a échouée")
        }
        
        let json: [String:Any] = [
            "company_fk": companyId,
            "audit_fk": auditId,
            "is_profil_pic": true,
            "base_image": base64EncodedImage!,
            "type": "png"
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        request.httpBody = jsonData
        

        let (data, response) = try await URLSession.shared.data(for: request)
        
        print(String(decoding: data, as: UTF8.self))
        
        print(response)


        guard (response as? HTTPURLResponse)!.statusCode >= 200 && (response as? HTTPURLResponse)!.statusCode <= 299 else {
            throw ServerErrorType.internalError(reason: "L'upload de l'image a échouée")
        }
        
        let receivedJson = try? JSONSerialization.jsonObject(with: data, options: [])

        guard receivedJson != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }
        
        if let dic = receivedJson as? [String:Any] {
            let path: String = dic["path_to_image"]! as! String
            return path
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
    }
    
    /**
     
        Method to create a measure
        - Parameters:
        - subcriterion: sub criterion data
        - stepId: id reference of the substep
        - auditId: id reference of the audit
        - criterionId: id reference of the criterion
     */

    func createMeasure(subcriterion: DataNorm, stepId: Int, auditId: Int, criterionId: Int) async throws -> Int {
        var json: [String:Any] = [:]
        let comment = getCommentFromRegulationNormArray(regNorms: subcriterion.data)
        let value = getValueFromRegulationNormArray(regNorms: subcriterion.data)

        if subcriterion.idSubCriterion == nil {
            json = [
                "name": subcriterion.data[0].instruction,
                "photo": "",
                "comment": comment,
                "result": value,
                "recommendation": "",
                "step_fk": stepId,
                "criterion_fk": criterionId,
            ]
        }
        else {
            json = [
                "name": subcriterion.data[0].instruction,
                "photo": "",
                "comment": comment,
                "result": value,
                "recommendation": "",
                "step_fk": stepId,
                "criterion_fk": criterionId,
                "sub_criterion_fk": subcriterion.idSubCriterion,
            ]
        }
        
        if subcriterion.photoList.count > 0 {
            var id = 0
            for photo in subcriterion.photoList {
                // upload picture and get path
                let path = try await uploadImage(filename: photo, auditId: auditId)
                json["photo"] = path
                id = try await createMeasureHelperFunction(json: json)
            }
            return id
        } else {
            return try await createMeasureHelperFunction(json: json)
        }
    }
    
    /**
     
        API call to send feedback to our services

     */
    
    func sendFeedback(feedback: String) async throws -> Bool {
        
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""
        
        guard let url = URL(string: "http://51.103.72.63:3001/api/observation/") else { throw ServerErrorType.internalError(reason: "La construction de la requête envoyer un feedback a échouée") }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let unserialisedJson: [String: Any] = [
            "text": feedback
        ]
        
        guard let json = try? JSONSerialization.data(withJSONObject: unserialisedJson) else {
            throw ServerErrorType.internalError(reason: "Erreur lors de la construction de la requête")
        }
        
        request.httpBody = json
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ServerErrorType.internalError(reason: "L'envoi du message a échoué")
        }
        
        guard let userResponse = try? JSONDecoder().decode(Observation.self, from: data) else {
            throw ServerErrorType.internalError(reason: "La réponse du message n'a pas pu être décodée")
          }
        print("User feedback \(String(describing: userResponse.id))")
        return true
    }
    
    /**
            This function retrieve the list of criteria retrieved from the backend and save in a json file
     
     */
    
    func updateCriteriaList() -> Bool {
        var result = true
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        let email: String = UserDefaults.standard.string(forKey: "email") ?? ""
        
        guard let url = URL(string: "http://51.103.72.63:3001/api/criteria/all") else { return false }
        
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
            do {
                let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let pathToCriteriaList = userDirectory!.path + "/criteriaList"

                // create folder
                try FileManager.default.createDirectory(atPath: pathToCriteriaList, withIntermediateDirectories: true, attributes: nil)
                
                // create file
                let filename = pathToCriteriaList + "/" + "criteriaList.json"
                
                let string = String(data: data, encoding: String.Encoding.utf8)
                
                try string!.write(to: URL(fileURLWithPath: filename), atomically: true, encoding: String.Encoding.utf8)
                
            } catch {
                print("Error lors de la sauvegarde de la liste des critères: \(error).")
                result = false
            }
        }.resume()
        return result
    }
    
    /**
            Get subcriteria list from criterion Id
     */
    
    func getSubCriteriaFromCriterion(criterionName: String, criterionId: Int) async throws -> [RegulationCheckField] {
        //http://51.103.72.63:3001/api/sub_criterion/criterion?criterionId=1
        
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        
        guard let url = URL(string:
                                "http://51.103.72.63:3001/api/sub_criterion/criterion?criterionId=\(criterionId)") else { throw ServerErrorType.internalError(reason: "La construction de la requête pour obtenir des sous critère a échouée") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        var regs: [RegulationCheckField] = []
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ServerErrorType.internalError(reason: "La requête pour obtenir des sous critères à partir de l'id du critere (\(criterionId)) a échouée")
        }
        
        if String(decoding: data, as: UTF8.self) == "[]" {
            // leave subCriterion Id as null
            regs = [RegulationCheckField(key: criterionName,
                                         type: TypeField.bool,
                                         text: criterionName,
                                         optional: false
                                        )]
        } else {
            let json = try? JSONSerialization.jsonObject(with: data, options: [])
            
            guard json != nil else {
                throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
            }
            
            if let dictionary = json as? [[String: Any]] {
                for obj in dictionary {
                    let subcriterionName = obj["name"]! as! String
                    let subcriterionId = obj["id"]! as! Int
                    
                    regs.append(RegulationCheckField(
                        key: subcriterionName,
                        type: TypeField.bool,
                        text: subcriterionName,
                        optional: false,
                        idSubCriterion: subcriterionId
                    ))
                }
            } else {
                throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
            }
        }
        return regs
    }
    
    /**
     
        Get place criteria from place Ids
     */
    
    func getCriteriaFromPlace(placeId: Int) async throws -> [(String, Int)] {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        
        guard let url = URL(string:
                                "http://51.103.72.63:3001/api/criterion/place?placeId=\(placeId)") else { throw ServerErrorType.internalError(reason: "La construction de la requête pour obtenir des critères a échouée") }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        var criteriaList: [(String, Int)] = []
        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
//            throw ServerErrorType.internalError(reason: "La requête pour obtenir des critères à partir de l'id de la place (\(placeId)) a échouée")
            // silence this throw because the data in its self contains holes
            print("La requête pour obtenir des critères à partir de l'id de la place (\(placeId)) a échouée")
            return []
        }
        
        
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        
        guard json != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }
        
        if let dictionary = json as? [[String: Any]] {
            for obj in dictionary {
                let criterionName = obj["name"]! as! String
                let criterionId = obj["id"]! as! Int

                criteriaList.append((criterionName, criterionId))
            }
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
        return criteriaList
    }

    /**
     
        Get all the places from area Id
     */
    
    func getPlaceFromArea(areadId: Int) async throws -> [Int] {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        
        guard let url = URL(string: "http://51.103.72.63:3001/api/place/area?areaId=\(areadId)") else { throw ServerErrorType.internalError(reason: "La construction de la requête pour obtenir des  places a échouée") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        var placeList: [Int] = []
        
//        do {
        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ServerErrorType.internalError(reason: "La requête pour obtenir des places à partir de l'id de l'endroit (\(areadId)) a échouée")
        }
        
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        guard json != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }
        
        if let dictionary = json as? [[String: Any]] {
            for obj in dictionary {
                let placeId = obj["id"]! as! Int
                placeList.append(placeId)
            }
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
        return placeList
    }
    
    /**
     
        Request the backend to get all stages and criteria given the buildingId, return a StageRead list
     
     */
    
    func getAllStages(buildingTypeId: Int) async throws -> [String:StageRead] {
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""
        
        guard let url = URL(string: "http://51.103.72.63:3001/api/area/building?buildingId=\(buildingTypeId)") else { throw ServerErrorType.internalError(reason: "La construction de la requête pour obtenir des endroits a échouée") }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        var stages: [String:StageRead] = [:]
        
        let (data, response) = try await URLSession.shared.data(for: request)

        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ServerErrorType.internalError(reason: "La requête pour obtenir des endroits à partir de l'id du batiment (\(buildingTypeId)) a échouée")
        }

        let json = try? JSONSerialization.jsonObject(with: data, options: [])

        guard json != nil else {
            throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
        }

        if let dictionary = json as? [[String: Any]] {
            for obj in dictionary {
                let areaId = obj["id"] as! Int
                let placesId: [Int]  = try await self.getPlaceFromArea(areadId: areaId)
                for placeId in placesId {
                    let criteria: [(String, Int)] = try await self.getCriteriaFromPlace(placeId: placeId)
                    for criterion in criteria {
                        let criterionName = criterion.0
                        let criterionId = criterion.1
                        let criterias: [RegulationCheckField] = try await self.getSubCriteriaFromCriterion(criterionName: criterionName, criterionId: criterionId)
                        stages[criterionName] = StageRead(name: criterionName, content: criterias, idBuilding: buildingTypeId, idArea: areaId, idPlace: placeId, idCriterion: criterionId)
                    }
                }
            }
        } else {
            throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
        }
        return stages
    }
    
    /**
     
        Download all criteria from all building types
     
     */
    
    func downloadAllCriteria() async throws -> [[StageRead]]  {
        // list of all criteria from different building type
        var criteriaObject: [[StageRead]] = []
        let accessToken: String = UserDefaults.standard.string(forKey: "token") ?? ""

        for buildingId in (1...173) {
            
            guard let url = URL(string: "http://51.103.72.63:3001/api/area/building?buildingId=\(buildingId)") else { throw ServerErrorType.internalError(reason: "La construction de la requête pour obtenir des endroits a échouée") }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)

            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw ServerErrorType.internalError(reason: "La requête pour obtenir des endroits à partir de l'id du batiment (\(buildingId)) a échouée")
            }

            let json = try? JSONSerialization.jsonObject(with: data, options: [])

            guard json != nil else {
                throw ServerErrorType.internalError(reason: "Erreur de la deserialization de l'objet json")
            }
            
            if let dictionary = json as? [[String: Any]] {
                for obj in dictionary {
                    let areaId = obj["id"] as! Int
                    let placesId: [Int]  = try await self.getPlaceFromArea(areadId: areaId)
                    for placeId in placesId {
                        let criteria: [(String, Int)] = try await self.getCriteriaFromPlace(placeId: placeId)
                        if criteria.count == 0 {
                            continue
                        }
                        for criterion in criteria {
                            let criterionName = criterion.0
                            let criterionId = criterion.1
                            let criterias: [RegulationCheckField] = try await self.getSubCriteriaFromCriterion(criterionName: criterionName, criterionId: criterionId)
                            if buildingId == criteriaObject.count {
                                criteriaObject[buildingId - 1].append(StageRead(name: criterionName, content: criterias, idBuilding: buildingId, idArea: areaId, idPlace: placeId, idCriterion: criterionId))
                            } else {
                                criteriaObject.append([StageRead(name: criterionName, content: criterias, idBuilding: buildingId, idArea: areaId, idPlace: placeId, idCriterion: criterionId)])
                            }
                        }
                    }
                }
            } else {
                throw ServerErrorType.internalError(reason: "La tentative de casting sur l'objet json a échouée")
            }
        }
        return criteriaObject
    }
 }
