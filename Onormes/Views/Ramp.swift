//
//  Ramp.swift
//  Onormes
//
//  Created by gonzalo on 11/05/2022.
//

import Foundation
import SwiftUI

class RampStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator, key: String = "empty") {  // build its stage array
        super.init(config: config, coordinator: coordinator, key: "rampe")
        
        self.steps.append(subStepsMap["rampe-1"]!)
    }
    
    override func modify(coordinator: UJCoordinator) -> Bool {
        // check to lead the next steps
        // retrieve answers from the first step
        if index == 0 {
            if steps[0].dataContainer.data["automatique"]!.valueCheckBox == true && steps[0].dataContainer.data["amovible"]!.valueCheckBox == true {
                // TODO: missed something here check PLD
                self.steps.append(subStepsMap["rampe-2"]!)
                
                self.steps.append(subStepsMap["rampe-3"]!)
                
                self.steps.append(subStepsMap["rampe-4"]!)
            }
            
            if steps[0].dataContainer.data["permanente"]!.valueCheckBox == true || steps[0].dataContainer.data["posée"]!.valueCheckBox == true {
                self.steps.append(subStepsMap["rampe-18"]!)
            }
            
            self.steps.append(subStepsMap["rampe-5"]!)
            self.steps.append(subStepsMap["rampe-6"]!)
            self.steps.append(subStepsMap["rampe-7"]!)
            self.steps.append(subStepsMap["rampe-8"]!)
            self.steps.append(subStepsMap["rampe-9"]!)
            self.steps.append(subStepsMap["rampe-10"]!)
            self.steps.append(subStepsMap["rampe-11"]!)
            self.steps.append(subStepsMap["rampe-12"]!)
            self.steps.append(subStepsMap["rampe-13"]!)
            
            // handle permanente ou posée
            self.steps.append(subStepsMap["rampe-14"]!)
            
            self.steps.append(subStepsMap["rampe-15"]!)
            
            self.steps.append(subStepsMap["rampe-16"]!)
            
            self.steps.append(subStepsMap["rampe-17"]!)
        }
        return true
    }
}
