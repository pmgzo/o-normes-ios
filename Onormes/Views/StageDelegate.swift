//
//  StageDelegate.swift
//  Onormes
//
//  Created by gonzalo on 10/07/2022.
//

import Foundation

class PRegulationCheckStageDelegate  {
    var steps: [GenericRegulationView] = []
    var index: Int = 0
    var coordinator: UJCoordinator;
    var id: String
    var savedData: [DataNorm] = [];
    
    init(config: ERP_Config, coordinator: UJCoordinator, key: String) {
        self.id = key + "-" + UUID().uuidString
        print("pStageDelegate ctor")
        self.index = 0
        self.coordinator = coordinator
    }
    
    func getNextStep() -> GenericRegulationView {

        if savedData.count != 0 && index < savedData.count {
            // reload the data
            steps[index].reloadSavedData(savedData: savedData[index])
        }
        
        if index >= steps.count {
            return GenericRegulationView(title: "Empty Page", content: [], id: "emptypage", subStepId: "emptypage")
        }
        
        return steps[index]
    }
    
    func getPreviousStep() -> GenericRegulationView {
        // index should have been changed previously
        if index < 0 || index > steps.count - 1 {
            // empty
            return GenericRegulationView(title: "Empty Page", content: [], id: "emptypage", subStepId: "emptypage")
        }
        return steps[index]
    }
    
    func stillHaveSteps()  -> Bool {
        return index < steps.count
    }
    
    func hasStillPreviousSteps() -> Bool {
        return !(index == 0)
    }
    
    func formIsOkay() -> Bool {
        print("form is okay ")
        return steps[index].formIsOkay()
    }
    
    func modify(coordinator: UJCoordinator) -> Bool {
        return steps[index].modify(coordinator: coordinator)
    }
    
    func loadData(newSavedData: [DataNorm]) {
        self.savedData = newSavedData
    }
    
    // call once the user decide to go back
    func reloadPreviousStage(previousId: String, newSavedData: [DataNorm]) {
        
        //TODO: modify maybe
        if newSavedData.count == 0 {
            return
        }

        id = previousId
        self.steps = []
        
        // we have to full copy it because the journey can change according to our previous choices
        for subStep in newSavedData {
            steps.append(subStepsMap[subStep.subStepId]!)
        }
        self.loadData(newSavedData: newSavedData)
        self.index =  newSavedData.count
    }
    
    func reloadDuringTheStage(newSavedData: [DataNorm]) {
        self.loadData(newSavedData: newSavedData)
        self.index =  savedData.count
    }
    
    func loadPreviousStep() {
        self.index -= 1
        steps[self.index].reloadSavedData(savedData: savedData[self.index])
    }
    
    func getCurrentSubStepId() -> String {
        return steps[index].subStepId!
    }
}
