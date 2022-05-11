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
        self.steps.append(GenericRegulationView(title: "Page allée structurante", content: [RegulationCheckField(key: "alléestructurante", type: TypeField.string, text: "Saisissez la largeur du couloir, (le couloir doit avoir au minimum 1.20m de largeur)", optional: false)], id: "alléestructurante"))
    }
}

class NonPublicCorridorStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        self.steps.append(GenericRegulationView(title: "Page allée non structurante", content: [RegulationCheckField(key: "alléenonstructurante", type: TypeField.string, text: "Saisissez la largeur du couloir, (le couloir doit avoir au minimum 1.05m de largeur au sol et 90cm à partir de 0.2m de hauteur)", optional: false)], id: "alléenonstructurante"))
    }
}

struct Coridor_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            //DoorView(coordinator: UJCoordinator())
            GenericRegulationView(title: "Page allée structurante", content: [RegulationCheckField(key: "alléestructurante", type: TypeField.string, text: "Saisissez la largeur du couloir, (le couloir doit avoir au minimum 1.20m de largeur)", optional: false)], id: "alléestructurante")
        }
      }
  }
