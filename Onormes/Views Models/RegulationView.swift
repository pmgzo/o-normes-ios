//
//  RegulationView.swift
//  Onormes
//
//  Created by gonzalo on 11/07/2022.
//

import Foundation
import SwiftUI

protocol PRegulationCheckViewModel: ObservableObject, Identifiable {
    func addRegulationCheck(coordinator: UJCoordinator, data: [String:RegulationNorm], content: [RegulationCheckField], subStepId: String) -> Bool
    func formIsOkay(data: [String:RegulationNorm]) -> Bool
}

class GenericRegulationViewModel: PRegulationCheckViewModel {
    //@State var data: [String : String] = [:];
    var mandatoryItems: Set<String>;
    var id: String;

    init() {
        self.id = ""
        self.mandatoryItems = []
    }
    
    func changeState(id: String, content: [RegulationCheckField]) -> Void {
        self.id = id
        for (_, reg) in content.enumerated() {
            if !reg.optional {
                mandatoryItems.insert(reg.key)
            }
        }
    }
    
    func changeId(id: String) -> Void {
        self.id = id
    }

    
    func formIsOkay(data: [String:RegulationNorm]) -> Bool {
        // check mandatory field

        if mandatoryItems.isEmpty {
            return true
        }
        
        for (_, regname) in mandatoryItems.enumerated() {
            
            if data[regname]!.type != TypeField.bool &&  data[regname]!.valueMetric == "" {
                return false
            }
        }
        
        return true
    }

    func addRegulationCheck(coordinator: UJCoordinator, data: [String:RegulationNorm], content: [RegulationCheckField], subStepId: String) -> Bool {
        if formIsOkay(data: data) {
            // TODO: maybe to change because we need the key if we need to go back to the previous state
            var newObject = DataNorm(key: self.id, data: [], subStepId: subStepId)
            for (_, value) in data {
                newObject.data.append(value)
            }
            // TODO: to modify
            coordinator.addNewRegulationCheck(newObject: newObject)
            
            return true
        }
        return false
    }
    
    func displayError(data: [String:RegulationNorm]) -> Bool {
        // check mandatory field
        return !formIsOkay(data: data)
    }
}

