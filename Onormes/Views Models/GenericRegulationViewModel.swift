//
//  GenericRegulationViewModel.swift
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

/**
 This class is created by the **GenericRegulationView** class. This class manages the data saving of each substeps by communicating directly with the **UserJourneyCoordinator** class.
 */

class GenericRegulationViewModel: PRegulationCheckViewModel {
    var mandatoryItems: Set<String>;
    var id: String;

    init() {
        self.id = ""
        self.mandatoryItems = []
    }
    
    /**
        This function is used once we get back to a previous stage and need to reload preivous steps. Some stage are conditional and thus the future substeps might differ, so we reload each validated substeps. Basically this function reload each substeps validated previously.
        
        - Parameters:
            - id: previous stage id
            - content: previous filled substeps
     */
    
    func changeState(id: String, content: [RegulationCheckField]) -> Void {
        self.id = id
        for (_, reg) in content.enumerated() {
            if !reg.optional {
                mandatoryItems.insert(reg.key)
            }
        }
    }
    
    /**
        This function is used once we get back to a previous stage and need to reload preivous steps. It changes the current id of the current step

        - Parameters:
        - id:new id
     */
    
    func changeId(id: String) -> Void {
        self.id = id
    }

    /**
        This function validate or not the substep, if the mandatory field are not filled then the fonction return **false**.
     - Parameters:
        - data: list of each form''s value
        - Returns: if the form is completely filled (for the mandatory field at least)
     */
    func formIsOkay(data: [String:RegulationNorm]) -> Bool {
        // check mandatory field

        if mandatoryItems.isEmpty {
            return true
        }
        
        for (_, regname) in mandatoryItems.enumerated() {
            if data[regname]!.type != TypeField.bool &&  data[regname]!.valueString == "" {
                return false
            }
        }
        
        return true
    }

    /**
            This method validates and saves written data of this current substep (once the user click on the next button
        - Parameters:
        - coordinator: coordinator
        - data: dictionary containing the form's data
     
        - Returns: boolean value which return **false** if the some field are missing and **true** if all is okay.

     */
    
    func addRegulationCheck(coordinator: UJCoordinator, data: [String:RegulationNorm], content: [RegulationCheckField], subStepId: String) -> Bool {
        if formIsOkay(data: data) {
            // TODO: maybe to change because we need the key if we need to go back to the previous state
            var newObject = DataNorm(key: self.id, data: [], subStepId: subStepId, idSubCriterion: content[0].idSubCriterion)
            for (_, value) in data {
                newObject.data.append(value)
            }
            // TODO: to modify
            coordinator.addNewRegulationCheck(newObject: newObject)
            
            return true
        }
        return false
    }
    
    /**
        TODO: DO NOT SHOW
        
        This function notices the **GenericRegulationView** if some fields are missing
        - Parameters:
        - data:  dictionary containing the form's data
        - Returns: boolean value which return **false** if the some field are missing and **true** if all is okay.

     */
    func displayError(data: [String:RegulationNorm]) -> Bool {
        // check mandatory field
        return !formIsOkay(data: data)
    }
}


