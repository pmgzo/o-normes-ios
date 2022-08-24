//
//  WaitingLine.swift
//  Onormes
//
//  Created by gonzalo on 10/05/2022.
//

import Foundation
import SwiftUI

class WaitingLineStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        self.steps.append(getSubSteps(id: "filedattente-1"))
    }
}

struct WaitingLine_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            //DoorView(coordinator: UJCoordinator())
            getSubSteps(id: "filedattente-1")
        }
      }
  }
