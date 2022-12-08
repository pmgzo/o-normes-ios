//
//  Structures.swift
//  Onormes
//
//  Created by gonzalo on 09/09/2022.
//

import Foundation

// get user struct
struct User: Decodable {
    let id: Int?
    let first_name: String?
    let last_name: String?
    let email: String?
    let password: String?
    let logo: String?
    let phone_number: String?
    let birth_date: String?
    let password_reset_token: String?
    let password_reset_expiration_date: String?
    let registration_token: String?
    let status_fk: Int?
    let deleted: Bool?
    let name: String?
    let address: String?
}

// structure for retrieving feedback
struct Observation: Decodable {
    let id: Int?
    let text: String?
    let user_fk: Int?
    let status_fk: Int?
}
