//
//  Elevator.swift
//  Onormes
//
//  Created by gonzalo on 10/05/2022.
//

import Foundation
import SwiftUI

class ElevatorStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        
        self.steps.append(getSubSteps(id: "ascenseur-1"))
        self.steps.append(getSubSteps(id: "ascenseur-2"))
        self.steps.append(getSubSteps(id: "ascenseur-3"))
//        self.steps.append(getSubSteps(id: "ascenseur-4"))
//        self.steps.append(getSubSteps(id: "ascenseur-5"))
    }
}

struct Elevator_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            getSubSteps(id: "ascenseur-1")
        }
      }
  }
