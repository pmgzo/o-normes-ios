//
//  Door.swift
//  Onormes
//
//  Created by gonzalo on 01/04/2022.
//

import Foundation
import SwiftUI

class DoorStageDelegate: PRegulationCheckStageDelegate {
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator);
        
        self.steps.append(getSubSteps(id: "portedentrée-1"));
    }
}

struct DoorView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
        getSubSteps(id: "portedentrée-1")
    }
  }
}
