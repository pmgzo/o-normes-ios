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
        self.steps.append(GenericRegulationView(title: "Porte d'entrée", content: [RegulationCheckField(key: "portedentrée", type: TypeField.string, text: "Saisissez la largeur de la porte d'entrée", optional: false)], id: "portedentrée"));
        //steps.append(DoorView(coordinator: coordinator))
    }
}

struct DoorView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
        //DoorView(coordinator: UJCoordinator())
        GenericRegulationView(title: "Porte d'entrée", content: [RegulationCheckField(key: "portedentrée", type: TypeField.string, text: "Saisissez la largeur de la porte d'entrée")], id: "portedentrée")
    }
  }
}
