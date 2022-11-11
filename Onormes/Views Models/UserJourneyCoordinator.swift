//
//  UserJourneyCoordinator.swift
//  Onormes
//
//  Created by gonzalo on 16/03/2022.
//

import Foundation
import SwiftUI

enum UJCoordinatorError: Error {
    case attributeNotSet(name: String)
}

/**
 
This class is the user journey class dedicated to control all the data flow during the user journey navigation

- Properties:
    - myDictionary: saved data of each stage
    - done: check to see if the user journey is finished
    - auditRef: unique Id of the current user journey
    - stageHistory: array containing each keys of the contained stages in the current user journey
    - index: index of the current stage
    - stageDelegate: current stage of the user journey (the stageDelegate manages its own substeps)
 */

class UJCoordinator: ObservableObject {
    //model data

    // old saved stage's data
    private var myDictionary: [String:[DataNorm]] = [:] // TODO: to remove

    // saved stage's data
    private var savedData: [StageWrite] = []

    // stage to be included during the diagnostic
    private var stageList:  [String:StageRead] = [:]
    
    var auditInfos: AuditInfos;

    var getStageNames: [String] {
        get {
            return Array(stageList.keys)
        }
    }
    
    var getSavedData: [StageWrite] {
        return savedData
    }

    var dataAudit: [DataNorm] {
        get {
            var array: [DataNorm] = []
            
            for (_, steps) in self.myDictionary {
                for subStep in steps {
                    array.append(subStep)
                }
            }
            return array
        }
    }

    // nav properties
    
    var done: Bool {
        get {
            return self.finished == true || (!self.stillHaveStage() && self.stageDelegate!.hasFinished && self.wentBack == false)
        }
    }
    
    var hasFinished: Bool {
        return finished
    }
    
    // audit, general information:
    var auditRef: String;
    
    // stages properties
    private var wentBack: Bool = false;
    private var stageHistory: [String];
    private var index: Int;
    //var stageDelegate: PRegulationCheckStageDelegate?;
    
    //state properties
    var stageDelegate: StageDelegate?;
    var totalStages: Int = 0;
    private var finished = false
    
    init() {
        print("UJCoordinator initialized")
        self.auditRef = UUID().uuidString;

        self.index = 0
        self.stageHistory = []
        
        self.stageDelegate = nil

        self.stageHistory = []
        self.myDictionary = [:]
        
        // temporary set auditInfos
        self.auditInfos = AuditInfos(buildingType: "",
                                     name: "",
                                     buildingName: "",
                                     address: "",
                                     siret: "",
                                     email: "",
                                     phoneNumber: "",
                                     notes: "",
                                     date: Date())
    }
    
    /*
        Load filled steps from file
    */
    
    func loadPath(pathToLoad: String) { // TODO: modify with JSON
        self.myDictionary = convertJsonToStep(path: pathToLoad)
        
        self.stageHistory = Array(self.myDictionary.keys)
        self.index = self.stageHistory.count - 1
        
        self.stageDelegate = nil
        
        // get it from json
        //self.auditRef = UUID().uuidString;
        let startIndex = pathToLoad.index(pathToLoad.endIndex, offsetBy: -6-35)
        let endIndex = pathToLoad.index(pathToLoad.endIndex, offsetBy: -6)
        let range = startIndex...endIndex
        self.auditRef = String(pathToLoad[range])
        print("new audit ref \(self.auditRef)")
    }

    /**
     
        This function stores all the possible stages to add for the selected building type
     */

    func loadBuildingTypeStages(stages: [String:StageRead]) {
        self.stageList = stages
    }
    
    /**
        This function is used for navigation  button, if the user can not go back to the previous step during the user journey, usually its because no substep or stages have been validated so far.
     */
    
    func canGoBack() -> Bool {
        return stageDelegate == nil || !(index == 0 && self.stageDelegate!.currentlyIntheFirstStep())
    }
    
    /**
        This method is used for reset the **wentBack** property once the user clicked on next step button.s
        
     */
    
    func resetWentBack() -> Void {
        self.wentBack = false
    }
    
    /**
        This method is to check if the UserJourney has any stage left.
     */
    
    func stillHaveStage() -> Bool {
        return self.stageHistory.count > (self.index + 1)
    }
    
    /**
        This method return the current stage id
        - Returns: return the current stage id
     */
    
    func getCurrentStageId() -> String {

        if self.stageDelegate != nil && self.stageHistory.count > 0 {
            return self.stageHistory[index]
        }
        return "unknown"
    }
    

    // record data

    /**
                Get audit infos, called in the summary page
     */

    
    func getAuditInfos() -> AuditInfos {
        return auditInfos
    }
    
    /**
            Once the user fills out the audit infos in the audit creation page, this function is called
     */
    
    func setAuditInfos(auditInfos: AuditInfos) {
        self.auditInfos = auditInfos
    }
    
    
    /**
            Function to update saved data, called in the summary page when user change data
     
     */
    
    func updateSavedData(modifiedData: [StageWrite]) {
        savedData = modifiedData
        
        stageHistory = []
        
        for stage in modifiedData {
            stageHistory.append(stage.stageName)
        }
        
        self.index = stageHistory.count
    }
    
    /**
        This function adds new stages in the user journey after adding stage in the **RegulationsSelection** page.
        
        **Parameters**:
        - ids: selected ids in the **RegulationsSelection** page
     */

    func addRegulationCheckStages(ids: Set<String>) {
        for id in ids {
            //build the stage id here
            //self.stageHistory.append(id + "-" + UUID().uuidString)
            self.stageHistory.append(id)
            
            let stageRef = stageList[id]!
            
            let idBuilding = stageRef.idBuilding
            let idArea = stageRef.idArea
            let idPlace = stageRef.idPlace
            let idCriterion = stageRef.idCriterion
            
            self.savedData.append(
                StageWrite(stageName: id, description: "", data: [], idBuilding: idBuilding, idArea: idArea, idPlace: idPlace, idCriterion: idCriterion)
            )
        }
        self.totalStages = self.stageHistory.count
        
        // handle add step during summary page
        if self.finished == true {
            self.userJourneyNotFinished()
            self.startTheNewStage()
        }
    }

    /**
        This function saves data once the user click on the next step button

     **Parameters**
- newObject: object to be saved
     
     */
    
    func addNewRegulationCheck(newObject: DataNorm) {
        let stageId = self.index
        let dataNormId = self.stageDelegate!.getIndex

        if self.savedData[stageId].data.count > 0 && dataNormId <= (savedData[stageId].data.count - 1) {
            self.savedData[stageId].data[dataNormId] = newObject
        } else {
            self.savedData[stageId].data.append(newObject)
        }
    }
    
    func addStageDescription(description: String) -> Bool {
        self.savedData[self.index].description = description
        return true
    }
    
    /**
     
     This function add description to the current stage
     
     */
    
    func changeDescription(description: String) {
        print("description = \(description)")
        self.savedData[self.index].description = description
    }
    
    
    /**
     
     This function is saving the current saved data into a json file
     
     */
    
    func writeDataIntoJsonFile() -> Void {
        
        // TODO: to refacto, change the data structure
        
        do {
            let obj = convertStepIntoJson(data: myDictionary)

            if JSONSerialization.isValidJSONObject(obj) {
                
                //print("1")
                let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                let pathToSavedAudit = userDirectory!.path + "/savedAudit"
                
                //print("3")
                try FileManager.default.createDirectory(atPath: pathToSavedAudit, withIntermediateDirectories: true, attributes: nil)
                
                // TODO: to remove
                // remove previous file in the directory
                let allFiles = try FileManager.default.contentsOfDirectory(atPath: pathToSavedAudit)
                for file in allFiles {
                    try FileManager.default.removeItem(atPath: pathToSavedAudit + "/" + file)
                }
                
                //print(FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask))
                
                //jsonData.write(to: )
                //print("4")

                let data = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                //print("5")

                let string = String(data: data, encoding: String.Encoding.utf8)
                //print("6")
                //print(string)

                let filename = pathToSavedAudit + "/" + self.auditRef + ".json"
                //print(filename)
                //print(string)
                //print("7")
                try string!.write(to: URL(fileURLWithPath: filename), atomically: true, encoding: String.Encoding.utf8)
                //print("8")
                // TODO: to remove
//                let allFiles = try FileManager.default.contentsOfDirectory(atPath: pathToSavedAudit)
//                print("9")
//                for file in allFiles {
//                    print(file)
//                }
                    
            }
            
        } catch {
            print("Unexpected error: \(error).")
            print("erreur lors de la sauvegarde du json")
        }
    }
    
    


    // used once the stages are added at the end of the summary
    func startTheNewStage() {
        self.stageDelegate = StageDelegate(coordinator: self, stageRead: stageList[self.stageHistory[self.index]]!)
    }
    
    /**
        This function change the **stageDelegate** property. This function is called once we get to a new stage or once the user journey is done
     */
    
    func changeDelegate() {
        self.index += 1
        
        if self.index < self.stageHistory.count {

            self.stageDelegate = StageDelegate(coordinator: self, stageRead: stageList[self.stageHistory[self.index]]!)
            
            if savedData[self.index].data.count > 0 || savedData[self.index].description != "" {
                let previousId = self.stageHistory[self.index]

                // ensure that the loaded stage retrieve all stored data
                self.stageDelegate!.reloadFilledStage(
                    previousId: previousId,
                    stageWrite: savedData[self.index]
                )
            }

        } else {
            // set user journey to finished
            self.userJourneyFinished()
        }
        
        // save in json file
        //self.writeDataIntoJsonFile()
    }
    
    /**
        This function enables us to get to the new stage or new substep.

**Parameters**
- start: variable used for the first substep of the user journey

     */
    
    func nextStep(start: Bool = false) { // user has click to the next step button
        if self.wentBack == true && !self.stageDelegate!.stillHaveSteps() {
            self.resetWentBack()
        }
        
        if start == true {
            print("start")
            stageDelegate = StageDelegate(coordinator: self, stageRead: stageList[self.stageHistory[0]]!)
        }
        else {
            print("move Index")
            // TODO: we change the stage at that moment in the User Journey Coordinator and not in the delegate class
            self.stageDelegate!.moveIndex()

            if self.stageDelegate!.hasFinished {
                self.changeDelegate()
            }
        }
    }
    
    /**
        This function ask the model part of the app, to get the next **GenericRegulationView** (substep)
        Called once the user click to the next button.

**Parameters**:
- forceQuit: variable to display directly the summary page and send the audit
     
     */
    
    func getNextView() -> GenericRegulationView {
        if hasFinished {
            // summary page
            return GenericRegulationView(coordinator: self)
        } else {
            return self.stageDelegate!.getNextStep()
        }
    }
    
    /**
        This function reload the previous data written by the user in order to get to the previous stage.
        This function loads also the previous validated steps
     */
    
    func backToThePreviousStage() {
        self.wentBack = true
        
        // go previous stage
        if self.hasFinished || (self.stageDelegate!.currentlyIntheFirstStep()) {

            self.index -= 1
            
            self.stageDelegate = StageDelegate(
                coordinator: self,
                stageRead: stageList[self.stageHistory[self.index]]!)
            let previousId = self.stageHistory[self.index]

            // reload saved data for data model
            self.stageDelegate!.reloadPreviousStage(
                previousId: previousId,
                stageWrite: savedData[self.index],
                stageRead: stageList[previousId]!)
            self.stageDelegate!.loadPreviousStep()
        }
        
        // go previous step
        else if !self.stageDelegate!.currentlyIntheFirstStep() {

            self.stageDelegate?.reloadDuringTheStage(newSavedData: savedData[self.index].data)
            self.stageDelegate?.loadPreviousStep()
        }
    }
    
    /**
        This function load the previous view after reloading the previous stage.
     */
    
    func getPreviousView() -> GenericRegulationView {
        return self.stageDelegate!.getPreviousStep()
    }
    
    func userJourneyFinished() {
        finished = true
    }
    
    func userJourneyNotFinished() {
        finished = false
    }
}

