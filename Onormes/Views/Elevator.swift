//
//  Elevator.swift
//  Onormes
//
//  Created by gonzalo on 10/05/2022.
//

import Foundation
import SwiftUI

class ElevatorStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator, key: String = "empty") {  // build its stage array
        super.init(config: config, coordinator: coordinator, key: "ascenseur")
        
        self.steps.append(subStepsMap["ascenseur-1"]!)
        self.steps.append(subStepsMap["ascenseur-2"]!)
        self.steps.append(subStepsMap["ascenseur-3"]!)
        self.steps.append(subStepsMap["ascenseur-4"]!)
        self.steps.append(subStepsMap["ascenseur-5"]!)
    }
}

struct Elevator_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            subStepsMap["ascenseur-1"]!
        }
      }
  }
