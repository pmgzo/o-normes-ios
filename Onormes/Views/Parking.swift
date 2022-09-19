//
//  Parking.swift
//  ExternalPath.swift
//  Onormes
//
//  Created by gonzalo on 19/09/2022.
//

import Foundation
import SwiftUI

class ParkingStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        
        self.steps.append(getSubSteps(id: "parking-1"))
        self.steps.append(getSubSteps(id: "parking-2"))
        self.steps.append(getSubSteps(id: "parking-3"))
        self.steps.append(getSubSteps(id: "parking-4"))
    }
}
