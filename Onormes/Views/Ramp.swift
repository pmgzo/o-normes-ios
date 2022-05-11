//
//  Ramp.swift
//  Onormes
//
//  Created by gonzalo on 11/05/2022.
//

import Foundation
import SwiftUI

class RampStageDelegate: PRegulationCheckStageDelegate {
    
    override init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        super.init(config: config, coordinator: coordinator)
        
        self.steps.append(GenericRegulationView(title: "Choisissez le type de Rampe", content: [
            RegulationCheckField(key: "permanente", type: TypeField.bool, text: "Permanente", optional: false),
            RegulationCheckField(key: "amovible", type: TypeField.bool, text: "Amovible", optional: false),
            RegulationCheckField(key: "posée", type: TypeField.bool, text: "Posée", optional: false),
            RegulationCheckField(key: "intégré", type: TypeField.bool, text: "Intégré (à justifier si la rampe n'est pas intégrée)", optional: false),
            RegulationCheckField(key: "automatique", type: TypeField.bool, text: "Automatique", optional: false)
            ], id: "rampe")
        )
    }
    
    override func modify(coordinator: UJCoordinator) -> Bool {
        // check to lead the next steps
        // retrieve answers from the first step
        if index == 0 {
            if steps[0].data["automatique"] as! Bool == true && steps[0].data["amovible"] as! Bool == true {
                // TODO: missed something here check PLD
                self.steps.append(GenericRegulationView(title: "Rampe (pour automatique et amovible)", content: [RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "Hauteur comprise entre 0,90 m et 1,30 m (mesurée depuis l'espace d'emprise de la rampe)", optional: false)], id: "rampe"))
                
                self.steps.append(GenericRegulationView(title: "Rampe (pour automatique et amovible)", content: [RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "L'usager est informé de la prise en compte de son appel", optional: false)], id: "rampe"))
                
                self.steps.append(GenericRegulationView(title: "Rampe (pour automatique et amovible)", content: [RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "Les employés de l'établissement sont formés à la manipulation et au deploiement de la rampe", optional: false)], id: "rampe"))
            }
            
            if steps[0].data["permanente"] as! Bool == true || steps[0].data["posée"] as! Bool == true {
                self.steps.append(GenericRegulationView(title: "Rampe (pour permanente ou posée)", content: [
                    RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "La rampe ne présente pas de vide latéraux", optional: false)], id: "rampe"))
            }
            
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "Le dispositif mis en place pour permettre l'acces est visible et accessible", optional: false)], id: "rampe")
            )
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "airdemanoeuvre", type: TypeField.bool, text: "L'air de manoeuvre en haut et en bas de la rampe respect les dimensions minimale suivante: 1.20 x 1.40", optional: false)], id: "rampe")
            )
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe peut supporter une masse minimal de 300kg", optional: false)], id: "rampe")
            )
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe est suffisament large pour accueillir une personne en fauteuil roulant", optional: false)], id: "rampe")
            )
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe est non-glissante", optional: false)], id: "rampe")
            )
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe est contrastée par son environnement", optional: false)], id: "rampe")
            )
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe est constituée de matériaux opaques", optional: false)], id: "rampe")
            )
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe doit respecter la règle fonctionelle d'acces à l'angle droit (L1 + L2 > 2m)", optional: false)], id: "rampe")
            )
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Le plan incliné a une largeur minimum de 80cm", optional: true)], id: "rampe")
            )
            
            // handle permanente ou posée
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Le signalement est situé à proximité de la porte d'entrée", optional: false)], id: "rampe")
            )
            
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Les signalements sont facilement repérables", optional: false)], id: "rampe")
            )
            
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Les signalements sont visuellement contrastés vis à vis de son support", optional: false)], id: "rampe")
            )
            
            self.steps.append(GenericRegulationView(title: "Rampe", content: [
                RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Les signalements sont situés au droit d'une signalisation visuelle (ex: panneau) pour expliciter sa signification", optional: false)], id: "rampe")
            )
        }
        return true
    }
}
