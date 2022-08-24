//
//  Ramp.swift
//  Onormes
//
//  Created by gonzalo on 11/05/2022.
//

import Foundation
import SwiftUI

class RampStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        
        self.steps.append(getSubSteps(id: "rampe-1"))
    }
    
    override func modify(coordinator: UJCoordinator) -> Bool {
        // check to lead the next steps
        // retrieve answers from the first step
        if index == 0 {
            if steps[0].dataContainer.data["automatique"]!.valueCheckBox == true && steps[0].dataContainer.data["amovible"]!.valueCheckBox == true {
                // TODO: missed something here check PLD
                self.steps.append(getSubSteps(id: "rampe-2"))
                
                self.steps.append(getSubSteps(id: "rampe-3"))
                
                self.steps.append(getSubSteps(id: "rampe-4"))
                self.steps.append(getSubSteps(id: "rampe-14"))
            }
            
            if steps[0].dataContainer.data["permanente"]!.valueCheckBox != true {
                self.steps.append(getSubSteps(id: "rampe-18"))
            }
            
            self.steps.append(getSubSteps(id: "rampe-5"))
            self.steps.append(getSubSteps(id: "rampe-6"))
            self.steps.append(getSubSteps(id: "rampe-7"))
            self.steps.append(getSubSteps(id: "rampe-8"))
            self.steps.append(getSubSteps(id: "rampe-9"))
            self.steps.append(getSubSteps(id: "rampe-10"))
            self.steps.append(getSubSteps(id: "rampe-11"))
            self.steps.append(getSubSteps(id: "rampe-12"))
            self.steps.append(getSubSteps(id: "rampe-13"))
            
            // handle permanente ou posée
            
            
            
            self.steps.append(getSubSteps(id: "rampe-15"))
            
            self.steps.append(getSubSteps(id: "rampe-16"))
            
            self.steps.append(getSubSteps(id: "rampe-17"))
        }
        return true
    }
}
