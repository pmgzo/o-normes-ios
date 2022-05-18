//
//  Elevator.swift
//  Onormes
//
//  Created by gonzalo on 10/05/2022.
//

import Foundation
import SwiftUI

class ElevatorStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator, key: String = "empty") {  // build its stage array
        super.init(config: config, coordinator: coordinator, key: "ascenseur")
        
        //separate steps into single pages
        
        self.steps.append(GenericRegulationView(title: "Ascenseur", content: [
                RegulationCheckField(key: "commandeascenseur", type: TypeField.string, text: "Les commandes intérieures doit avoir une hauteur du sol comprise entre 0.9m et 1.2m", optional: false)
        ], id: self.id))
        self.steps.append(GenericRegulationView(title: "Ascenseur", content: [
            RegulationCheckField(key: "ascenseurmaincourante", type: TypeField.string, text: "La main courante doit être comprise entre 87.5cm et 92.5cm", optional: false)], id: self.id))
        self.steps.append(GenericRegulationView(title: "Ascenseur", content: [
            RegulationCheckField(key: "ascenseurcatune", type: TypeField.bool, text: "Ascenseur type 1: 1,25m x 1m avec un passage libre de 80cm", optional: false)], id: self.id))
        self.steps.append(GenericRegulationView(title: "Ascenseur", content: [
            RegulationCheckField(key: "ascenseurcatdeux", type: TypeField.bool, text: "Ascenseur type 2: 1.10m x 1.40m avec un passage libre de 90cm", optional: false)
        ], id: self.id))
        self.steps.append(GenericRegulationView(title: "Ascenseur", content: [
            RegulationCheckField(key: "ascenseurcattrois", type: TypeField.bool, text: "Ascenseur type 3: 2m x 1.40m avec un passage libre de 1.1m", optional: false)
        ], id: self.id))
    }
}

struct Elevator_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            //DoorView(coordinator: UJCoordinator())
            GenericRegulationView(title: "File d'attente", content: [RegulationCheckField(key: "filedattente", type: TypeField.bool, text: "L'appuis ischiatique est à une hauteur d'environ 0.70m ", optional: true)], id: "filedattente")
        }
      }
  }
