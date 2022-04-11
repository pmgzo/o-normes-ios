//
//  Door.swift
//  Onormes
//
//  Created by gonzalo on 01/04/2022.
//

import Foundation
import SwiftUI

enum ViewModelUserJouneyError: Error {
    case missedInitializedVariable
}

class DoorViewModel: ObservableObject, Identifiable {
    @Published var doorWidth: Float?;
    @Published var doorComment: String?;
    private var  key = "Door";
    
    private unowned let coordinator: UJCoordinator;
    
    init(coordinator: UJCoordinator) {
        self.coordinator = coordinator
        
    }
    
    // in case he goes back to the step
    init(coordinator: UJCoordinator, data: String) {
        self.coordinator = coordinator
        // TODO: reload data with the string

    }
    
    func getId() -> String {
        return "external-door"
    }
    
    func formIsOkay() -> Bool {
        if doorWidth != nil { return true }
        // to the checking
        // if it is okay
        return false
    }
    
    func registerJSONObject() throws -> Void {
        guard doorWidth == nil else {
            throw ViewModelUserJouneyError.missedInitializedVariable
        }
        
        let wrappedObject: NSDictionary = ["doorWidth": self.doorWidth, "doorComment": self.doorComment != nil ? self.doorComment : ""]
        
        // send it to coordinator
        self.coordinator.addNewRegulationCheck(newObject: wrappedObject, newKey: self.key)
    }
    
    // useless
    func completeForm() -> Void {
        // discuss with the coordinator to do so
    }
}

struct DoorView: View {
    // handle form and save in json
    @ObservedObject var viewModel: DoorViewModel;
    
    var body: some View {
        VStack {
            Text("Door model form")
            // add form
        }
    };
}
