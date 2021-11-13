//
//  UIApplication Extension.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 06/11/2021.
//

import SwiftUI
import UIKit

extension UIApplication {
  func endEditing() {
    sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}

extension Color {
  init(hex: UInt, alpha: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xff) / 255,
      green: Double((hex >> 08) & 0xff) / 255,
      blue: Double((hex >> 00) & 0xff) / 255,
      opacity: alpha
    )
  }
}
