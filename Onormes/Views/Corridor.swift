//
//  Corridor.swift
//  Onormes
//
//  Created by gonzalo on 10/05/2022.
//

import Foundation
import SwiftUI

class CorridorStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator, key: String = "empty") {  // build its stage array
        super.init(config: config, coordinator: coordinator, key: "alléestructurante")
        self.steps.append(subStepsMap["alléestructurante-1"]!)
    }
}

class NonPublicCorridorStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator, key: String = "empty") {  // build its stage array
        super.init(config: config, coordinator: coordinator, key: "alléenonstructurante")
        self.steps.append(subStepsMap["alléenonstructurante-1"]!)
    }
}

struct Coridor_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            //DoorView(coordinator: UJCoordinator())
            subStepsMap["alléestructurante-1"]!
        }
      }
  }
