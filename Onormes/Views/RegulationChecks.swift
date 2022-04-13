//
//  RegulationChecks.swift
//  Onormes
//
//  Created by gonzalo on 12/04/2022.
//

import Foundation
import SwiftUI

struct ERP_Config {
    //TODO: see what check needs to be added
    let hasMultipleFloor: Bool = true
    let hasElevator: Bool = true // maybe not usefull
}

// example measure component should inherit of this

// TODO: Have to merge with PRegulationCheckView
protocol PRegulationPage {
    var coordinator: UJCoordinator { get };

    init(coordinator: UJCoordinator) // params have to think about it
}

protocol PRegulationCheckModel {
    var regChecks: [PRegulationPage] { get }
    var key: String { get }; // key for the saved json field

    init(configs: ERP_Config) // here the array of PRegulationPage is built
    // load UUID string for the key
    func getNextStep() -> PRegulationPage
}
