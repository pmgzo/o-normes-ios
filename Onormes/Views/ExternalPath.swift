//
//  Ramp.swift
//  ExternalPath.swift
//  Onormes
//
//  Created by gonzalo on 19/09/2022.
//

import Foundation
import SwiftUI

class ExternalPathStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        
        self.steps.append(getSubSteps(id: "cheminementexterieur-1"))
        self.steps.append(getSubSteps(id: "cheminementexterieur-2"))
        self.steps.append(getSubSteps(id: "cheminementexterieur-3"))
        self.steps.append(getSubSteps(id: "cheminementexterieur-4"))
        self.steps.append(getSubSteps(id: "cheminementexterieur-5"))
    }
    
    override func modify(coordinator: UJCoordinator) -> Bool {
        if index == 5 {
            
            if steps[5].dataContainer.data["plan"]!.valueCheckBox == true {
                self.steps.append(getSubSteps(id: "cheminementexterieur-6"))
            }
            self.steps.append(getSubSteps(id: "cheminementexterieur-7"))
        }
        return self.steps[index].modify(coordinator: coordinator)
    }
}
