//
//  UserJourneyCoordinator.swift
//  Onormes
//
//  Created by gonzalo on 16/03/2022.
//

import Foundation
import SwiftUI

//TODO: IntroUJCoordinator
// fill form
// give the drive to UJCoordinator

class UJCoordinator: ObservableObject {
    //model data
    private var myDictionary: NSMutableDictionary = [:]
    
    // audit, general information
    private var auditRef: String;
    var config: ERP_Config;
    
    // stages
    private var stageHistory = [String]();
    private var stageDelegate: PRegulationCheckStageDelegate?;
    private var index: Int;
    
    @Published var value: Bool;

    init() {
        print("UJCoordinator initialized")
        value = true
        //self.doorView = DoorViewModel(coordinator: self);
        self.auditRef = UUID().uuidString;
        self.config = ERP_Config()

        self.stageHistory = ["porte d'entrée"]
        self.index = 0
        //TODO: add initial step here !!
        //TODO: init stage history + stageDelegate
        
        self.stageDelegate = DoorStageDelegate(config: self.config, coordinator: self)
    }
    
    // record data
    func addNewRegulationCheck(newObject: NSDictionary, newKey: String) {
        let newGeneratedKey = newKey + UUID().uuidString;
        myDictionary[newGeneratedKey] = newObject
        stageHistory.append(newGeneratedKey)
    }
    
    // add steps/stages, (id list) as parameters
    func addRegulationCheckStages(ids: Set<String>) {
        // set next stages
        
    }
    
    func getNextStep<T: PRegulationCheckView>() throws -> T {
        if stageDelegate == nil {
            throw ViewModelUserJouneyError.stageNotInitialized
        }
        
        if (stageDelegate!.stillHaveSteps()) {
            return stageDelegate!.getNextStep()
        }
        
        // then we change stage
        if index == (stageHistory.count - 1) {
            //TODO: return recap page
            return UJCoordinatorView() as! T
        } else {
            stageDelegate = getStageMap()[stageHistory[index]] as! PRegulationCheckStageDelegate
            return stageDelegate!.getNextStep()
        }
    }
}

extension UJCoordinator {
  // new features here
    func getStageMap() -> NSDictionary {
        let stageMap: NSDictionary = [
            "porte d'entrée" : DoorStageDelegate(config: self.config, coordinator: self),
        ]
        return stageMap
    }
    
}


//TODO: to remove
struct UJCoordinatorView: PRegulationCheckView {
    // wrong coordinator
    @ObservedObject var coordinator: UJCoordinator;
    
    init() {
        coordinator = UJCoordinator()
    }
    // here we will wrapp view with the (+) to had new views
    var body: some View {
        VStack {
            if coordinator.value {
                Text("first view")
            } else {
                Text("second view")
                
            }
            Button("Change view") {
                print("coucou")
                withAnimation {
                    coordinator.value = !coordinator.value
                
                }}.buttonStyle(ButtonStyle())
        }
    }
    
    func check() -> Bool {
        return true
    }
    
    func modify() -> Bool {
        return true
    }
}

// Dummy page to remove
struct UserJourney: PRegulationCheckView {
    var coordinator: UJCoordinator;
    
    var body: some View {
        VStack {
//            List {
//                Text("Välkommen till User journey")
//                Text("Välkommen till User journey")
//            }
            // Have to handle layout
            Text("Simple user journey page that will be deleted")
        }
    }
    
    func startUserJourney()-> Void {
        print("jag börjar min User Journey")
    }
    
    func check() -> Bool {
        return true
    }
    
    func modify() -> Bool {
        return true
    }
}
