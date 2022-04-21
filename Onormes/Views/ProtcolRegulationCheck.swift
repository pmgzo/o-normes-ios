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

protocol PRegulationCheckStageDelegate  {
    var steps: Array<Any> { get };
    var index: Int {get};
    //associatedtype PRegulationCheckView
    
    init(config: ERP_Config, coordinator: UJCoordinator) // build its stage array
    func getFirstStep<T: PRegulationCheckView>() -> T
    func getNextStep<T: PRegulationCheckView>() -> T
    func stillHaveSteps() -> Bool
}

//class FirstPage: View, PRegulationCheck {
//
//}
