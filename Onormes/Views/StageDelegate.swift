//
//  StageDelegate.swift
//  Onormes
//
//  Created by gonzalo on 10/07/2022.
//

import Foundation

struct StageDelegate  {
    var descriptionPage: GenericRegulationView;
    var descriptionPagePassed: Bool
    var steps: [GenericRegulationView] = []
    var index: Int = 0
    var coordinator: UJCoordinator;
    var savedData: [DataNorm] = [];
    var hasFinished: Bool = false
    
    var getIndex: Int {
        get {
            return index
        }
    }
    
    private var _id: String
    var id: String {
      get {
          return self._id
      }
    }
    
    init(coordinator: UJCoordinator, stageRead: StageRead) {
        self._id = coordinator.getCurrentStageId()
        self.index = 0
        self.coordinator = coordinator
        
        self.steps = []
        for step in stageRead.content {
            //steps.append(GenericRegulationView(title: stageRead.name, content: [step], id: stageRead.name, subStepId: stageRead.name))
            steps.append(GenericRegulationView(title: stageRead.name, content: [step], id: stageRead.name, subStepId: step.text))
        }
        
        self.descriptionPage =  GenericRegulationView(coordinator: coordinator, description: "")
        self.descriptionPagePassed = false
    }
    
    /**
        Method to increase the index in the substeps list.
     */
    
    mutating func moveIndex() {
        
        if descriptionPagePassed == false {
            descriptionPagePassed = true
            return
        }
        self.index += 1
        if index == self.steps.count {
            hasFinished = true
        }
    }
    
    /**
            Method to get the next substep to be displayed
     
     */
    
    func getNextStep() -> GenericRegulationView {
        if descriptionPagePassed == false {
            return descriptionPage
        }
        if savedData.count != 0 && index < savedData.count {
            steps[index].reloadSavedData(savedData: savedData[index])
        }
        
        return steps[index]
    }
    
    /**
            Method to return the previous step
     */
    
    mutating func getPreviousStep() -> GenericRegulationView {
        if self.descriptionPagePassed == false {
            return descriptionPage
        }
        return self.steps[index]
    }
    

    
    func currentlyIntheFirstStep() -> Bool {
        if descriptionPagePassed == false {
            return true
        }
        return false
    }

    /**
     
        Method to indicate whether if the current stage has still substeps to be filled
        - Returns: boolean
     */
    
    
    func stillHaveSteps()  -> Bool {
        if self.descriptionPagePassed == false {
            return true
        }
        return (index + 1) < steps.count
    }
    
    /**
        Method to indicate if the current substep is the first one of the stage
        - Returns: boolean
     */

    func hasStillPreviousSteps() -> Bool {
        return !(index == 0 && self.descriptionPagePassed == false)
    }
    
    /**
        Method if the current substep is completely filled
        - Returns: boolean
     */
    
    func formIsOkay() -> Bool {
        if self.descriptionPagePassed == false {
            return true
        }
        return steps[index].formIsOkay()
    }
    
    /**
        Method to save data
     - Parameters:
            - coordinator: user journey coordinator
        - Returns: boolean to notice if the saving has failed
    */
    
    
    func modify(coordinator: UJCoordinator) -> Bool {
        print("modify")

        print(descriptionPagePassed)
        if self.descriptionPagePassed == false {
            print(self.descriptionPage.getDescription())
            print(self.descriptionPage.description)
            return coordinator.addStageDescription(description: self.descriptionPage.getDescription())
        }
        return steps[index].modify(coordinator: coordinator)
    }
    
    func addPicture(path: String) {
        if self.descriptionPagePassed == true {
            steps[index].addPicture(path: path)
        }
        // otherwise do not register the picture
    }

    /**
        Method change the current saved data (this function si called to reload the previous stage)
        - Parameters:
        - newSavedData: saved data
     */
    
    mutating func loadData(newSavedData: [DataNorm]) {
        self.savedData = newSavedData
    }
    
    /**
        Method which is called once the user decide to go back
     - Parameters:
     - previousId: previous stage Id
     - newSavedData: saved data
     */
    mutating func reloadPreviousStage(previousId: String, stageWrite: StageWrite, stageRead: StageRead) {
        print("reload preivous stage")
        
        let newSavedData = stageWrite.data
        
        self.descriptionPage =  GenericRegulationView(coordinator: coordinator, description: stageWrite.description)

        if newSavedData.count == 0 {
            // leave as no data has been saved
            return
        }
        
        self.descriptionPagePassed = true
        
        _id = previousId
        print(id)
        self.steps = []
        
        // we have to fully copy it because the journey can change according to our previous choices
        for subStep in stageRead.content {
            steps.append(
                GenericRegulationView(title: stageRead.name, content: [subStep], id: stageRead.name, subStepId: stageRead.name))
        }
        
        self.loadData(newSavedData: newSavedData)
        self.index =  newSavedData.count
    }
    
    /**
        Called once we get a back to an already filled stage
     - Parameters:
     - previousId: previous stage Id
     - stageWrite: saved data to be considered
     */
    mutating func reloadFilledStage(previousId: String, stageWrite: StageWrite) {
        
        self.savedData = stageWrite.data
        
        self.descriptionPage =  GenericRegulationView(coordinator: coordinator, description: stageWrite.description)

        _id = previousId
        self.index =  0
    }
    
    /**
        Method equivalent to **loadData**
     - Parameters:
     - newSavedData: saved data
     */
    
    mutating func reloadDuringTheStage(newSavedData: [DataNorm]) {
        self.loadData(newSavedData: newSavedData)
        //self.index =  savedData.count
    }
    
    /**
     
        Method to filled the previous page with the data that has been filled recently
     
     */
    mutating func loadPreviousStep() {
        if self.index != 0 {
            self.index -= 1
            steps[self.index].reloadSavedData(savedData: savedData[self.index])
        } else {
            descriptionPagePassed = false
        }
    }
    
    /**
            Method to get id of the current substep
     - Returns: id string
     */

    func getCurrentSubStepId() -> String {
        return steps[index].subStepId!
    }
}
