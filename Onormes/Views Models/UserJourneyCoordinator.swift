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

//TODO: IntroUJCoordinator Page (place, date, type of establishment, how many floor ? etc...)

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
    private var myDictionary: [String:[DataNorm]] = [:]
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
            return self.stageDelegate == nil || (!self.stillHaveStage() && self.stageDelegate!.hasFinished && self.wentBack == false)
        }
    }
    
    // audit, general information:
    
    var auditRef: String;
    var config: ERP_Config;
    
    // stages
    private var wentBack: Bool = false;
    private var stageHistory: [String];
    private var index: Int;
    var stageDelegate: PRegulationCheckStageDelegate?;
    var totalStages: Int = 0;
    
    init() {
        print("UJCoordinator initialized")
        self.auditRef = UUID().uuidString;
        self.config = ERP_Config()

        self.index = 0
        self.stageHistory = []
        self.stageDelegate = (self.getStageMap()["préétape"] as! PRegulationCheckStageDelegate)
        self.stageHistory.append(self.stageDelegate!.id)
        self.myDictionary[self.stageHistory[index]] = []
    }
    
    func loadPath(pathToLoad: String) {
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
        self.config = ERP_Config()
    }
    
    /**
        This function is used for navigation  button, if the user can not go back to the previous step during the user journey, usually its because no substep or stages have been validated so far.
     */
    
    func canGoBack() -> Bool {
        return stageDelegate == nil || !(index == 0 && stageDelegate!.index == 0)
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
        //print(self.stageHistory)
        
        if self.stageDelegate != nil && self.stageHistory.count > 0 {
            return self.stageHistory[index]
        }
        if self.stageHistory.count == 0 {
            //: doesn't works well because the UJ is reinitialise every but the value is not lost though ...
            return "portedentrée" + "-" + UUID().uuidString
        }
        return "unknown"
    }

    // record data

    /**
        This function saves data once the user click on the next step button

     **Parameters**
- newObject: object to be saved
     
     */
    
    func addNewRegulationCheck(newObject: DataNorm) {
        //TODO: to test !!
        
        if wentBack {
            //
            print("modify")
            let fetchId = newObject.subStepId
            for (i,obj_value) in myDictionary[self.stageDelegate!.id]!.enumerated() {
                if obj_value.subStepId == fetchId {
                    myDictionary[self.stageDelegate!.id]![i] = newObject
                    break
                }
            }
        }
        else {
            print("create")
            self.myDictionary[self.stageDelegate!.id]!.append(newObject)
        }
        
    }
    
    
    /**
     
     This function is saving the current saved data into a json file
     
     */
    
    func writeDataIntoJsonFile() -> Void {
        do {
            let obj = convertStepIntoJson(data: myDictionary)
            print(obj)
            print(JSONSerialization.isValidJSONObject(obj))
            if JSONSerialization.isValidJSONObject(obj) {
                
                print("1")
                let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
                print("2")
                let pathToSavedAudit = userDirectory!.path + "/savedAudit"
                
                
                
                print("3")
                
                // TODO: to remove
                let allFiles = try FileManager.default.contentsOfDirectory(atPath: pathToSavedAudit)
                print("before 3")
                
                for file in allFiles {
                    try FileManager.default.removeItem(atPath: pathToSavedAudit + "/" + file)
                }

                try FileManager.default.createDirectory(atPath: pathToSavedAudit, withIntermediateDirectories: true, attributes: nil)

                print(FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask))
                
                //jsonData.write(to: )
                print("4")

                let data = try JSONSerialization.data(withJSONObject: obj, options: .prettyPrinted)
                print("5")

                let string = String(data: data, encoding: String.Encoding.utf8)
                print("6")
                print(string)

                let filename = pathToSavedAudit + "/" + self.auditRef + ".json"
                print(filename)
                //print(string)
                print("7")
                try string!.write(to: URL(fileURLWithPath: filename), atomically: true, encoding: String.Encoding.utf8)
                print("8")
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
    
    
    /**
        This function adds new stages in the user journey after adding stage in the **RegulationsSelection** page.
        
        **Parameters**:
        - ids: selected ids in the **RegulationsSelection** page
     */

    func addRegulationCheckStages(ids: Set<String>) {
        //print(ids)
        for id in ids {
            //build the stage id here
            self.stageHistory.append(id + "-" + UUID().uuidString)
        }
        self.totalStages = self.stageHistory.count
    }

    /**
        This function change the **stageDelegate** property. This function is called once we get to a new stage or once the user journey is done
     */
    
    func changeDelegate() {
        self.index += 1
        print("changeDelegate")
        
        if self.index < self.stageHistory.count {
            let trueId = parseNormId(stageHistory[index])
            // TODO: have to handle when you already write something and then you want back to a previous stage, we need a way to reload the previous data we had
            self.stageDelegate = (self.getStageMap()[trueId] as! PRegulationCheckStageDelegate)
            self.myDictionary[self.stageHistory[index]] = []
        } else {
            self.stageDelegate = nil
        }
        
        // save in json file
        self.writeDataIntoJsonFile()
    }
    
    /**
        This function enables us to get to the new stage or new substep.

**Parameters**
- start: variable used for the first substep of the user journey

     */
    
    func nextStep(start: Bool = false) { // user has click to the next step button
        print("go next step")
        
        if self.wentBack == true && !self.stageDelegate!.stillHaveSteps() {
            self.resetWentBack()
        }

        if start == false {
            //TODO: we change the stage at that moment in the User Journey Coordinator and not in the delegate class
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
    
    func getNextView(forceQuit: Bool = false) -> GenericRegulationView {
        if forceQuit == true || index == stageHistory.count || stageDelegate!.hasFinished {
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
        // TODO: check, maybe move the index of the previous delegate, maybe it will erase when we go to previous stage, add stg to load in the next features
        
        self.wentBack = true
        print("back 0")
        if self.stageDelegate == nil || (self.stageDelegate!.index == 0) {// go previous stage
            print("previous stage")
            self.index -= 1
            print("index ==")
            print(index)
            print(self.stageHistory)
            // reload data
            print(self.wentBack)
            self.stageDelegate = (self.getStageMap()[parseNormId(self.stageHistory[self.index])] as! PRegulationCheckStageDelegate)
            let previousId = self.stageHistory[self.index]

            // reload saved data for data model
            self.stageDelegate!.reloadPreviousStage(previousId: previousId,newSavedData: self.myDictionary[previousId]!)
            self.stageDelegate!.loadPreviousStep()
        }
        
        else if self.stageDelegate!.index > 0 { // go previous stage's substep
            print("previous step")

            self.stageDelegate?.reloadDuringTheStage(newSavedData: self.myDictionary[self.stageDelegate!.id]!)
            self.stageDelegate?.loadPreviousStep()
        }
    }
    
    /**
        This function load the previous view after reloading the previous stage.
     */
    
    func getPreviousView() -> GenericRegulationView {
        //TODO: check if we can load the previous step otherwise, we keep the current scene
        
        if self.stageDelegate == nil {
            return GenericRegulationView(title: "Empty Page", content: [], id: "emptypage", subStepId: "emptypage")
        }
        return self.stageDelegate!.getPreviousStep()
    }
}

extension UJCoordinator {
    /**
     This function enables us to reload properly the previous steps, once we need to go back to the previous stage.
     */
    func getStageMap() -> NSDictionary {
        let stageMap: NSDictionary = [
            "préétape": PrestageStageDelegate(config: self.config, coordinator: self),
            "portedentrée" : DoorStageDelegate(config: self.config, coordinator: self),
            "rampe" : RampStageDelegate(config: self.config, coordinator: self),
            "alléestructurante" : CorridorStageDelegate(config: self.config, coordinator: self),
            "alléenonstructurante" : NonPublicCorridorStageDelegate(config: self.config, coordinator: self),
            "escalier" : StairsStageDelegate(config: self.config, coordinator: self),
            "ascenseur" : ElevatorStageDelegate(config: self.config, coordinator: self),
            "filedattente" : WaitingLineStageDelegate(config: self.config, coordinator: self)
        ]
        return stageMap
    }
}
