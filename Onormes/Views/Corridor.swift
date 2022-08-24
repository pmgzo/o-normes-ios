//
//  Corridor.swift
//  Onormes
//
//  Created by gonzalo on 10/05/2022.
//

import Foundation
import SwiftUI

class CorridorStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        self.steps.append(getSubSteps(id: "alléestructurante-1"))
    }
}

class NonPublicCorridorStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        self.steps.append(getSubSteps(id: "alléenonstructurante-1"))
    }
}

struct Coridor_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            //DoorView(coordinator: UJCoordinator())
            getSubSteps(id: "alléestructurante-1")
        }
      }
  }
