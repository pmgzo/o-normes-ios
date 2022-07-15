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
// fill form


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
            return self.stageDelegate == nil || (!self.stillHaveStage() && !self.stageDelegate!.stillHaveSteps() && self.wentBack == false)
        }
    }
    
    // audit, general information
    let auditRef: String;
    var config: ERP_Config;
    
    // stages
    private var wentBack: Bool = false;
    private var stageHistory = [String]();
    private var index: Int;
    var stageDelegate: PRegulationCheckStageDelegate?;
    var totalStages: Int = 0;
    
    @Published var value: Bool;

    init() {
        print("UJCoordinator initialized")
        value = true
        self.auditRef = UUID().uuidString;
        self.config = ERP_Config()

        self.index = 0
        self.stageDelegate = self.getStageMap()["portedentrée"] as! PRegulationCheckStageDelegate
        self.stageHistory = [self.stageDelegate!.id]
        self.myDictionary[self.stageHistory[index]] = []
    }

    // record data
    func addNewRegulationCheck(newObject: DataNorm) {
        
        if wentBack {
            let fetchId = newObject.subStepId
            for (i,value) in myDictionary[self.stageDelegate!.id]!.enumerated() {
                if value.subStepId == fetchId {
                    myDictionary[self.stageDelegate!.id]![i] = newObject
                    break
                }
            }
        }
        else {
            myDictionary[self.stageDelegate!.id]!.append(newObject)
        }
        // TODO: when we go back and revalidate a step
    }
    
    func backToThePreviousStage() {
        // TODO: check, maybe move the index of the previous delegate, maybe it will erase when we go to previous stage, add stg to load in the next features
        
        self.wentBack = true
        
        if self.stageDelegate == nil || (self.stageDelegate!.index == 0 && self.index > 0) {// go previous stage
            self.index -= 1
            // reload data
            self.stageDelegate = (getStageMap()[parseNormId(stageHistory[index])] as! PRegulationCheckStageDelegate)
            let previousId = self.stageHistory[index]

            // reload saved data for data model
            self.stageDelegate?.reloadPreviousStage(previousId: previousId,newSavedData: myDictionary[previousId]!)
            self.stageDelegate?.loadPreviousStep()
        }
        
        else if self.stageDelegate!.index > 0 { // go previous stage's substep

            self.stageDelegate?.reloadDuringTheStage(newSavedData: myDictionary[self.stageDelegate!.id]!)
            self.stageDelegate?.loadPreviousStep()
        }
    }
        
    func canGoBack() -> Bool {
        return !(index == 0 && stageDelegate!.index == 0)
    }

    func resetWentBack() -> Void {
        self.wentBack = false
    }
    
    // add steps/stages, (id list) s parameters
    func addRegulationCheckStages(ids: Set<String>) {
        for id in ids {
            stageHistory.append(id + "-" + UUID().uuidString)
        }
        totalStages = stageHistory.count
    }

    func changeDelegate() {
        self.index += 1
        print("changeDelegate")
        
        if self.index < self.stageHistory.count {
            let trueId = parseNormId(stageHistory[index])
            self.stageDelegate = getStageMap()[trueId] as! PRegulationCheckStageDelegate
            self.stageHistory[index] = self.stageDelegate!.id
            myDictionary[stageHistory[index]] = []
        } else {
            self.stageDelegate = nil
        }
    }
    
    func stillHaveStage() -> Bool {
        return self.stageHistory.count > (self.index + 1)
    }
    
    func getNextView(forceQuit: Bool = false) -> GenericRegulationView {
        
        if forceQuit == true || index == stageHistory.count || !(stageDelegate!.stillHaveSteps()) {
            // summary page
            return GenericRegulationView(coordinator: self)
        } else {
            return stageDelegate!.getNextStep()
        }
    }
    
    func getPreviousView() -> GenericRegulationView {
        //TODO: check if we can load the previous step otherwise, we keep the current scene
        
        if self.stageDelegate == nil {
            return GenericRegulationView(title: "Empty Page", content: [], id: "emptypage", subStepId: "emptypage")
        }
        
        return  self.stageDelegate!.getPreviousStep()
    }
    
    func nextStep(start: Bool = false) {
        print("go next step")

        self.resetWentBack()

        if start == false {

            self.stageDelegate?.index += 1

            if !self.stageDelegate!.stillHaveSteps() {
                self.changeDelegate()
            }
        }
    }
}

extension UJCoordinator {
  // new features here
    func getStageMap() -> NSDictionary {
        let stageMap: NSDictionary = [
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
