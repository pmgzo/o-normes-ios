//
//  RegulationCheckComponents.swift
//  Onormes
//
//  Created by gonzalo on 09/04/2022.
//

import Foundation
import SwiftUI

extension String {
    var floatValue: Float {
        return (self as NSString).floatValue
    }
}

//extension StringProtocol {
//    var double: Double? { Double(self) }
//    var float: Float? { Float(self) }
//    var integer: Int? { Int(self) }
//}

class MeasureComponentViewModel: PRegulationCheckViewModel {
    //TODO: check la string en details dasn formIsOkay
    @Published var value: String = "";
    @Published var comment: String = "";
    
    @Published var displayError: Bool = false;
    private let optional: Bool;

    init(optional: Bool=false) {
        self.optional = optional
    }
    
    func formIsOkay()->Bool {
        if !optional {

            if self.value != "" {
                displayError = false
                return true
            } else {
                displayError = true
                return false
            }
        }
        return true;
    }
    
    func addRegulationCheck(coordinator: UJCoordinator) -> Bool {
        //
        let wrappedObject: NSDictionary = ["length": (self.value as NSString).floatValue, "comment": self.comment ]
        
        // send it to coordinator
        coordinator.addNewRegulationCheck(newObject: wrappedObject, newKey: "measure") //temporary name
        return true;
    }
}


// to use that component you need to pass a view model, the above view is supposed to check the field of each field component before submiting the whole form
struct MeasureComponent: PRegulationCheckView {
    // TODO: add binding with AR view
    // TODO: add comment form put it as optional in ctor
    //TODO: add more parameter for that component to specifiy if that field is optional etc...
    let title: String;
    let action: (Float) -> Void; // used to modified
    @ObservedObject var model: MeasureComponentViewModel;
    private unowned let coordinator: UJCoordinator;
    
    init(coordinator: UJCoordinator, model: MeasureComponentViewModel, action: @escaping (Float) -> Void, title: String = "") {
        self.action = action
        self.title = title
        self.model = model
        self.coordinator = coordinator
    }

    var body: some View {
        HStack {
            // Formula
            VStack {
                Form {
                    Section(header: Text(title).foregroundColor(.black), footer: model.displayError ? Text("*champs obligatoire").foregroundColor(.red) : nil) {
                        TextField(title, text: $model.value).textFieldStyle(MeasureTextFieldStyle())
                        
                    }
                }.background(Color.gray.opacity(0))
            }
            // Button to switch to AR view
        }
    }
    
    func check() -> Bool {
        return model.formIsOkay()
    }
    
    func modify() -> Bool {
        return model.addRegulationCheck(coordinator: self.coordinator);
    }
}


struct MeasureComponent_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            MeasureComponent(coordinator: UJCoordinator(), model: MeasureComponentViewModel(), action: {(number) -> Void in print(number)}, title: "Porte hauteur")
            }
      }
  }
