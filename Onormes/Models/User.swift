//
//  Users.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 15/12/2021.
//

import Foundation

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
}
