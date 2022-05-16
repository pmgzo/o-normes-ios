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

class DataNorm: Identifiable {
    var id: String {key}
    
    let key: String
    let data: NSDictionary
    
    init(key: String, data: NSDictionary) {
        // data
        self.key = key
        self.data = data
    }
}

class UJCoordinator: ObservableObject {
    //model data
    private var myDictionary: [String:NSMutableDictionary] = [:]
    var dataAudit: [DataNorm] {
        get {
            var array: [DataNorm] = []
            
            for (key, value) in self.myDictionary {
                let newValue = NSDictionary(dictionary: value)
                array.append(DataNorm(key: key, data: newValue))
            }
            return array
        }
    }
    
    // audit, general information
    private var auditRef: String;
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
        myDictionary["porte d'entrée"] = NSMutableDictionary()
        //TODO: add initial step here !!
        //TODO: init stage history + stageDelegate
        
        self.stageDelegate = DoorStageDelegate(config: self.config, coordinator: self)
    }

    // record data
    func addNewRegulationCheck(newObject: NSDictionary, newKey: String) {
        // let newGeneratedKey = newKey + UUID().uuidString;
        
        myDictionary[stageHistory[index]]![newKey]! = newObject
        
        //stageHistory.append(newGeneratedKey)
    }
    
    // add steps/stages, (id list) s parameters
    func addRegulationCheckStages(ids: Set<String>) {
        // set next stages
        stageHistory = stageHistory + Array(ids)
        totalStages = stageHistory.count
    }

    func changeDelegate() {
        stageDelegate = getStageMap()[stageHistory[index]] as! PRegulationCheckStageDelegate
        myDictionary[stageHistory[index]] = NSMutableDictionary()
    }
    
    func stillHaveStage() -> Bool {
        return self.stageHistory.count > (self.index + 1)
    }
}

extension UJCoordinator {
  // new features here
    func getStageMap() -> NSDictionary {
        let stageMap: NSDictionary = [
            "porte d'entrée" : DoorStageDelegate(config: self.config, coordinator: self),
            "rampe d'entrée" : RampStageDelegate(config: self.config, coordinator: self),
            "allée structurante" : CorridorStageDelegate(config: self.config, coordinator: self),
            "allée non structurante" : NonPublicCorridorStageDelegate(config: self.config, coordinator: self),
            "escalier" : StairsStageDelegate(config: self.config, coordinator: self),
            "ascenseur" : ElevatorStageDelegate(config: self.config, coordinator: self),
            "file d'attente" : WaitingLineStageDelegate(config: self.config, coordinator: self)
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
