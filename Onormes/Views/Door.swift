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
    case stageNotInitialized
}

// Entrance door regulation check
class DoorViewModel: PRegulationCheckViewModel {
    @Published var doorWidth: String = "";
    @Published var doorComment: String = "";
    @Published var displayError: Bool = false;
    
    private var  key = "porte d'entrée";
    
    //private unowned let coordinator: UJCoordinator;
    
//    init(coordinator: UJCoordinator) {
//        self.coordinator = coordinator
//
//    }
    // in case he goes back to the step
//    init(coordinator: UJCoordinator, data: String) {
//        self.coordinator = coordinator
//        // TODO: reload data with the string
//
//    }
    
    func getId() -> String {
        return "external-door"
    }
    
    func formIsOkay() -> Bool {
        if doorWidth != nil && ((self.doorWidth as NSString).floatValue) >= 90.0 {
            displayError = false
            return true
        }
        else {
            displayError = true
        }
        // to the checking
        // if it is okay
        return false
    }
    
    func addRegulationCheck(coordinator: UJCoordinator) -> Bool {
        
        let wrappedObject: NSDictionary = ["doorWidth": (self.doorWidth as NSString).floatValue, "doorComment": self.doorComment != nil ? self.doorComment : ""]
        
        // send it to coordinator
        coordinator.addNewRegulationCheck(newObject: wrappedObject, newKey: self.key)
        return true
    }
    
    // useless
    func completeForm() -> Void {
        // discuss with the coordinator to do so
    }
}

struct DoorView: PRegulationCheckView {
    
    // handle form and save in json
    @ObservedObject var model = DoorViewModel();
//    private unowned let coordinator: UJCoordinator;
//
    var coordinator: UJCoordinator;
    
    init(coordinator: UJCoordinator) {
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            Text("Porte principale").font(.title)
            // add form
            
            Form {
                
                Spacer().frame(height: 130)
                
                Section(header: Text("Largeur de la porte").foregroundColor(.black), footer: model.displayError ? Text("*champs obligatoire").foregroundColor(.red) : nil) {
                    TextField("mesure", text: $model.doorWidth).textFieldStyle(MeasureTextFieldStyle())
                    
                    TextField("commentaire", text: $model.doorComment).textFieldStyle(CommentTextFieldStyle())
                        .multilineTextAlignment(TextAlignment.center)
                }
            }
            .background(Color.white)
            .onAppear { // ADD THESE
              UITableView.appearance().backgroundColor = .clear
            }

            Spacer()
        }
    }
    
    func check() -> Bool {
        return model.formIsOkay()
    }
    
    func modify() -> Bool {
        return model.addRegulationCheck(coordinator: self.coordinator)
    }
}

class DoorStageDelegate: PRegulationCheckStageDelegate {
    var steps: Array<Any>;
    var index: Int;

    required init(config: ERP_Config, coordinator: UJCoordinator) {  // build its stage array
        index = 0;
        steps = []
        steps.append(DoorView(coordinator: coordinator))
    }
    
    func getFirstStep<T>() -> T where T : PRegulationCheckView {
        //return steps[0] as! T
        return DoorView(coordinator: UJCoordinator()) as! T
    }
    
    func getNextStep<T>() -> T where T : PRegulationCheckView {
        index += 1
        return steps[index] as! T
    }
    
    func stillHaveSteps() -> Bool {
        if index == (steps.count - 1) {
            return false
        }
        return true
    }
}


struct DoorView_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            DoorView(coordinator: UJCoordinator())
        }
      }
  }
