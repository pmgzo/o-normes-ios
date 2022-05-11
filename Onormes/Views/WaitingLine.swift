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
        self.steps.append(GenericRegulationView(title: "File d'attente", content: [RegulationCheckField(key: "filedattente", type: TypeField.bool, text: "L'appuis ischiatique est à une hauteur d'environ 0.70m ", optional: true)], id: "filedattente"))
    }
}

struct WaitingLine_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            //DoorView(coordinator: UJCoordinator())
            GenericRegulationView(title: "File d'attente", content: [RegulationCheckField(key: "filedattente", type: TypeField.bool, text: "L'appuis ischiatique est à une hauteur d'environ 0.70m ", optional: true)], id: "filedattente")
        }
      }
  }
