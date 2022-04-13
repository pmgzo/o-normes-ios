//
//  ProtcolRegulationCheck.swift
//  Onormes
//
//  Created by gonzalo on 11/04/2022.
//

import Foundation
import SwiftUI

protocol PRegulationCheckView: View {
    var coordinator: UJCoordinator { get };
    
    func check() -> Bool
    func modify() -> Bool
}

protocol PRegulationCheckViewModel: ObservableObject, Identifiable {
    func addRegulationCheck(coordinator: UJCoordinator) -> Bool
    func formIsOkay() -> Bool
}

//class FirstPage: View, PRegulationCheck {
//
//}
