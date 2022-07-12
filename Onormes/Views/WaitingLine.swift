//
//  WaitingLine.swift
//  Onormes
//
//  Created by gonzalo on 10/05/2022.
//

import Foundation
import SwiftUI

class WaitingLineStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator, key: String = "empty") {  // build its stage array
        super.init(config: config, coordinator: coordinator, key: "filedattente")
        self.steps.append(subStepsMap["filedattente-1"]!)
    }
}

struct WaitingLine_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            //DoorView(coordinator: UJCoordinator())
            subStepsMap["filedattente-1"]!
        }
      }
  }
