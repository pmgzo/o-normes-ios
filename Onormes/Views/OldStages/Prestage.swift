//
//  Prestage.swift
//  Onormes
//
//  Created by gonzalo on 06/09/2022.
//

import Foundation
import SwiftUI

class PrestageStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        self.steps.append(getSubSteps(id: "préétape-1"))
        self.steps.append(getSubSteps(id: "préétape-2"))
    }
}
