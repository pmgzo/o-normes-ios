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
    //@Published var doorView: DoorViewModel?;
    //@Published var coridorView: CoridorViewModel;
    //@Published var doorView: ViewModel;
    private var myDictionary: NSMutableDictionary = [:]
    private var regulationCheckHistory = [String]();
    @Published var value: Bool;

    init() {
        print("UJCoordinator initialized")
        value = true
        //self.doorView = DoorViewModel(coordinator: self);
    }
    func addNewRegulationCheck(newObject: NSDictionary, newKey: String) {
        let newGeneratedKey = newKey + UUID().uuidString;
        myDictionary[newGeneratedKey] = newObject
        regulationCheckHistory.append(newGeneratedKey)
    }
}

//TODO: to remove (Main view root)
struct UJCoordinatorView: PRegulationCheckView {
    @ObservedObject var object: UJCoordinator;
    
    init() {
        object = UJCoordinator()
    }
    // here we will wrapp view with the (+) to had new views
    var body: some View {
        VStack {
            if object.value {
                Text("first view")
            } else {
                Text("second view")
                
            }
            Button("Change view") {
                print("coucou")
                withAnimation {
                    object.value = !object.value
                
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
