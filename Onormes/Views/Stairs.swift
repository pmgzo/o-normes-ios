//
//  Stairs.swift
//  Onormes
//
//  Created by gonzalo on 10/05/2022.
//

import Foundation
import SwiftUI

class StairsStageDelegate: PRegulationCheckStageDelegate {
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)

        self.steps.append(getSubSteps(id: "escalier-1"))
        self.steps.append(getSubSteps(id: "escalier-2"))
        self.steps.append(getSubSteps(id: "escalier-3"))
    }
}

struct Stairs_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            //DoorView(coordinator: UJCoordinator())
            GenericRegulationView(title: "Escalier", content: [
                RegulationCheckField(key: "largeurmaincourante", type: TypeField.string, text: "Saisissez la largeur entre main courant (La largeur minimum à respecter est de 1m)", optional: false),
                RegulationCheckField(key: "gironmarche", type: TypeField.string, text: "Saisissez la mesure du giron (g) (cette mesure doit respecter la relation Blondel : 60 cm < 2 h + g < 64cm)", optional: false),
                RegulationCheckField(key: "hauteurmarch", type: TypeField.string, text: "Saisissez la hauteur (h) de marche (cette mesure doit respecter la relation Blondel : 60 cm < 2 h + g < 64cm)", optional: false)
            ], id: "escalier", subStepId: "<randomId>")
        }
      }
  }
