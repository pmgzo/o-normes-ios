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

//TODO: IntroUJCoordinator
// fill form
// give the drive to UJCoordinator
// place, date, type of establishment, how many floor ? etc...

struct RegulationNorm: Identifiable {
    var id: String {get {return key}}
    
    let key: String;
    var valueMetric: String;
    var valueCheckBox: Bool;
    let instruction: String
    let mandatory: Bool;
    let type: TypeField;
    var comment: String;
    
    init(key: String, inst: String, type: TypeField, mandatory: Bool = true, valueString: String = "", valueBool: Bool = false) {
        self.key = key
        
        
        self.valueMetric = valueString
        self.valueCheckBox = valueBool
        self.comment = ""
        
        self.instruction = inst
        self.mandatory = mandatory
        self.type = type
    }
}

class DataNorm: Identifiable {
    var id: String {key}
    
    let key: String
    //let data: NSDictionary
    var data: [RegulationNorm]
    
    init(key: String, data: [RegulationNorm]) {
        // data
        self.key = key
        self.data = data
    }
}

class UJCoordinator: ObservableObject {
    //model data
    private var myDictionary: [String:DataNorm] = [:]
    var dataAudit: [DataNorm] {
        get {
            var array: [DataNorm] = []
            
            for (_, value) in self.myDictionary {
                array.append(value)
            }
            return array
        }
    }
    var done: Bool {
        get {
            return !self.stillHaveStage() && !self.stageDelegate!.stillHaveSteps()
        }
    }
    
    // audit, general information
    let auditRef: String;
    var config: ERP_Config;
    
    // stages
    private var stageHistory = [String]();
    private var index: Int;
    var stageDelegate: PRegulationCheckStageDelegate?;
    var totalStages: Int = 0;
    
    @Published var value: Bool;

    init() {
        print("UJCoordinator initialized")
        value = true
        //self.doorView = DoorViewModel(coordinator: self);
        self.auditRef = UUID().uuidString;
        self.config = ERP_Config()

        self.stageHistory = ["porte d'entrée"]
        self.index = 0
        //myDictionary["porte d'entrée"] = DataNorm(key: "porte d'entrée", data: [])
        
        //TODO: add initial step here !!
        //TODO: init stage history + stageDelegate
        
        self.stageDelegate = DoorStageDelegate(config: self.config, coordinator: self)
    }

    // record data
    func addNewRegulationCheck(newObject: DataNorm, newKey: String) {
        
        let newGeneratedKey = newKey
        // if it's the first stage
        if stageHistory.count == 1 {
            stageHistory[0] = newGeneratedKey
        } else {
            stageHistory.append(newGeneratedKey)
        }
        myDictionary[stageHistory[index]] = newObject
    }
    
    func backToThePreviousStage() {
        // TODO: check, maybe move the index of the previous delegate, maybe it will erase when we go to previous stage, add stg to load in the next features
        if self.stageDelegate!.index == 0 {
            // if first step we back to the previous stage
            self.index -= 1
            
            self.stageDelegate = getStageMap()[parseNormId(stageHistory[index])] as! PRegulationCheckStageDelegate
            print("beforeBack")
            print(self.stageDelegate!.index)
            //myDictionary[stageHistory[index]] = DataNorm(key: stageHistory[index], data: [])
        }
        if self.index > 0 {
            self.index -= 1
            self.stageDelegate = getStageMap()[parseNormId(stageHistory[index])] as! PRegulationCheckStageDelegate
            print("beforeBack")
            print(self.stageDelegate!.index)
            //myDictionary[stageHistory[index]] = DataNorm(key: stageHistory[index], data: [])
        }
    }
    
    func goToNextStage() {
        index += 1
    }

    
    // add steps/stages, (id list) s parameters
    func addRegulationCheckStages(ids: Set<String>) {
        // set next stages
        stageHistory = stageHistory + Array(ids)
        totalStages = stageHistory.count
    }

    func changeDelegate() {
        self.index += 1
        print("changeDelegate")
        
        if self.index < self.stageHistory.count {
            print("inside")
            let trueId = parseNormId(stageHistory[index])
            print(stageHistory[index])
            print(trueId)
            self.stageDelegate = getStageMap()[trueId] as! PRegulationCheckStageDelegate
            myDictionary[stageHistory[index]] = DataNorm(key: stageHistory[index], data: [])
        }
    }
    
    func stillHaveStage() -> Bool {
        return self.stageHistory.count > (self.index + 1)
    }
    
    func nextStep(forceQuit: Bool = false) -> GenericRegulationView {
        print("NextStep")
        print(index)
        print(stageHistory.count)
        
        if forceQuit == true || index >= stageHistory.count {
            // summary page
            return GenericRegulationView(coordinator: self)
        } else {
            return stageDelegate!.getNextStep()
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


////TODO: to remove
//struct UJCoordinatorView: PRegulationCheckView {
//    // wrong coordinator
//    @ObservedObject var coordinator: UJCoordinator;
//
//    init() {
//        coordinator = UJCoordinator()
//    }
//    // here we will wrapp view with the (+) to had new views
//    var body: some View {
//        VStack {
//            if coordinator.value {
//                Text("first view")
//            } else {
//                Text("second view")
//
//            }
//            Button("Change view") {
//                print("coucou")
//                withAnimation {
//                    coordinator.value = !coordinator.value
//
//                }}.buttonStyle(ButtonStyle())
//        }
//    }
//
//    func check() -> Bool {
//        return true
//    }
//
//    func modify() -> Bool {
//        return true
//    }
//}
//
//// Dummy page to remove
//struct UserJourney: PRegulationCheckView {
//    var coordinator: UJCoordinator;
//
//    var body: some View {
//        VStack {
////            List {
////                Text("Välkommen till User journey")
////                Text("Välkommen till User journey")
////            }
//            // Have to handle layout
//            Text("Simple user journey page that will be deleted")
//        }
//    }
//
//    func startUserJourney()-> Void {
//        print("jag börjar min User Journey")
//    }
//
//    func check() -> Bool {
//        return true
//    }
//
//    func modify() -> Bool {
//        return true
//    }
//}
