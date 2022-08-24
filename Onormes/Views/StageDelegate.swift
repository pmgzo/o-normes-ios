//
//  StageDelegate.swift
//  Onormes
//
//  Created by gonzalo on 10/07/2022.
//

import Foundation

/**
 This class is like an abstract class in C++. Each Stage class inherits from that class.
 This class implement the first simple step to handle substeps within a stage.
 
- Properties:
    - steps: are simple view corresponding to a substep
    - index: is the index of the current substep
    - coordinator: is the user journey coordinator, used to communicate between **UserJourneyCoordinator** and the **GenericViewModel**
    - savedData: is the date saved during the stage, to handle back button event
    - hasFinished: is a variable used to indicate to the **UserJourneyCoordinator** that the current stage is finished
 */

class PRegulationCheckStageDelegate  {
    var steps: [GenericRegulationView] = []
    var index: Int = 0
    var coordinator: UJCoordinator;
    var savedData: [DataNorm] = [];
    var hasFinished: Bool = false
    
    private var _id: String
    var id: String {
      get {
          return self._id
      }
    }
    
    init(config: ERP_Config, coordinator: UJCoordinator) {
        self._id = coordinator.getCurrentStageId()
        self.index = 0
        self.coordinator = coordinator
    }
    
    /**
        Method to increase the index in the substeps list.
     */
    
    func moveIndex() {
        self.index += 1
        if index == self.steps.count {
            hasFinished = true
        }
    }
    
    /**
            Method to get the next substep to be displayed
     
     */
    
    func getNextStep() -> GenericRegulationView {
        if savedData.count != 0 && index < savedData.count {
            // reload the data
            steps[index].reloadSavedData(savedData: savedData[index])
        }
        
        return steps[index]
    }
    
    /**
            Method to return the previous step
     */
    
    func getPreviousStep() -> GenericRegulationView {
        return self.steps[index]
    }
    
    /**
     
        Method to indicate whether if the current stage has still substeps to be filled
        - Returns: boolean
     */
    
    func stillHaveSteps()  -> Bool {
        return (index + 1) < steps.count
    }
    
    /**
        Method to indicate if the current substep is the first one of the stage
        - Returns: boolean
     */

    func hasStillPreviousSteps() -> Bool {
        return !(index == 0)
    }
    
    /**
        Method if the current substep is completely filled
        - Returns: boolean
     */
    
    func formIsOkay() -> Bool {
        print("form is okay ")
        return steps[index].formIsOkay()
    }
    
    /**
        Method to save data
     - Parameters:
            - coordinator: user journey coordinator
        - Returns: boolean to notice if the saving has failed
    */
    
    
    func modify(coordinator: UJCoordinator) -> Bool {
        return steps[index].modify(coordinator: coordinator)
    }
    
    /**
        Method change the current saved data (this function si called to reload the previous stage)
        - Parameters:
        - newSavedData: saved data
     */
    
    func loadData(newSavedData: [DataNorm]) {
        self.savedData = newSavedData
    }
    
    /**
        Method which is called once the user decide to go back
     - Parameters:
     - previousId: previous stage Id
     - newSavedData: saved data
     */
    func reloadPreviousStage(previousId: String, newSavedData: [DataNorm]) {
        
        //TODO: modify maybe
        if newSavedData.count == 0 {
            print("returned")
            return
        }

        _id = previousId
        print(id)
        self.steps = []
        
        // we have to fully copy it because the journey can change according to our previous choices
        for subStep in newSavedData {
            steps.append(getSubSteps(id: subStep.subStepId))
        }
        
        self.loadData(newSavedData: newSavedData)
        self.index =  newSavedData.count
        print("dataloaded")
    }
    /**
        Method equivalent to **loadData**
     - Parameters:
     - newSavedData: saved data
     */
    
    func reloadDuringTheStage(newSavedData: [DataNorm]) {
        self.loadData(newSavedData: newSavedData)
        //self.index =  savedData.count
    }
    
    /**
     
        Method to filled the previous page with the data that has been filled recently
     
     */
    func loadPreviousStep() {
        self.index -= 1
        steps[self.index].reloadSavedData(savedData: savedData[self.index])
    }
    
    /**
            Method to get id of the current substep
     - Returns: id string
     */

    func getCurrentSubStepId() -> String {
        return steps[index].subStepId!
    }
}
