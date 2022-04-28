//
//  ProtcolRegulationCheck.swift
//  Onormes
//
//  Created by gonzalo on 11/04/2022.
//

import Foundation
import SwiftUI

enum TypeField {
    case string
    case float
    case bool
}

class IntegerRef {
    let value: String
    init(_ value: String) {
        self.value = value
    }
}

struct RegulationCheckField: Identifiable, Equatable {
    var id: ObjectIdentifier
    
    let key: String;
    let type: TypeField;
    let text: String;
    let optional: Bool;
    let comment: String?;
    init(key: String, type: TypeField, text: String, optional: Bool = false) {
        self.key = key;
        self.type = type;
        self.text = text;
        self.optional = optional;
        self.comment = "";
        
        self.id = ObjectIdentifier(IntegerRef(UUID().uuidString))
    }
}

protocol PRegulationCheckViewModel: ObservableObject, Identifiable {
    func addRegulationCheck(coordinator: UJCoordinator) -> Bool
    func formIsOkay() -> Bool
}

//TODO: to complete
class GenericRegulationViewModel: PRegulationCheckViewModel
{
    //@Published var data: [String: String] = [:];
    @Published var data: NSMutableDictionary = [:]
    var mandatoryItems: Set<String>;
    let id: String;
    
    init(content: [RegulationCheckField], id: String) {
        // handle mandatory content
        self.id = id
        self.data = [:]
        self.mandatoryItems = []
        // set all the keys
        for (_, reg) in content.enumerated() {
            data[reg.key] = nil
            if !reg.optional {
                mandatoryItems.insert(reg.key)
            }
        }
    }
    
    func formIsOkay() -> Bool {
        // check mandatory field
        if mandatoryItems.isEmpty {
            return true
        }
        
        for (_, regname) in mandatoryItems.enumerated() {
            if data[regname] == nil {
                return false
            }
            else if data[regname] is String && data[regname] as! String == "" {
                return false
            }
        }
        
        return true
    }
    
    func addRegulationCheck(coordinator: UJCoordinator) -> Bool {
        // build a dictionary for coordinator
        // add id here in the json object
        
        
        return true;
    }
    
    func displayError() -> Bool {
        // check mandatory field
        return true;
    }
}

struct GenericRegulationView: View
{
    @ObservedObject var model: GenericRegulationViewModel
    let title: String?;
    let content: [RegulationCheckField]?;
    let id: String?;
    var isRegulationsPage = false;

    // for the regs page
    //associatedtype View
    //let regulationPageContent: View?;
    var navcoordinator: CustomNavCoordinator?;
    var coordinator: UJCoordinator?;
    @State var selectionTag: String?;
    @ObservedObject var selectedItems: SelectedRegulationSet;
    var gridItemLayout: [GridItem];
    
    init(title: String, content: [RegulationCheckField], id: String) {
        self.title = title
        self.content = content
        self.id = id + "-" + UUID().uuidString
        self.model = GenericRegulationViewModel(content: content, id:  self.id!)
        self.gridItemLayout = []
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
    }
    
    // for accessibility page
    init(coordinator: UJCoordinator, navcoordinator: CustomNavCoordinator) {
        self.navcoordinator = navcoordinator
        self.coordinator = coordinator
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        //self.regulationPageContent = content
        self.isRegulationsPage = true
        
        self.gridItemLayout = [GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86))]
        self.model = GenericRegulationViewModel(content: [], id:  "")
        self.title = "";
        self.content = [];
        self.id = "";
    }
    
    var body: some View {
        
        if self.isRegulationsPage {
            
            self.regulationsPage
        } else {
            VStack(alignment: .leading) {
                Text(self.title!).font(.title)
                Form {
                    Spacer().frame(height: 130)
                        
                    List(self.content!) { c in
                            //Text($0.name)
                        // TODO: to change
                        // model.displayError() ?
                        
                        Section(header: Text(c.text).foregroundColor(.black), footer: Text("*champs obligatoire").foregroundColor(.red)) {
                                // TODO: add check box condition or text
                                TextField("mesure", text: model.data[c.key] as! Binding<String>).textFieldStyle(MeasureTextFieldStyle())
                                    
                            TextField("commentaire", text: model.data[c.comment!] as! Binding<String>).textFieldStyle(CommentTextFieldStyle())
                                        .multilineTextAlignment(TextAlignment.center)
                                }
                        }
                }
                .background(Color.white)
                .onAppear { // ADD THESE
                  UITableView.appearance().backgroundColor = .clear
                }
                
                Spacer()
            }

        }
    }
    
    func formIsOkay() -> Bool {
        return self.model.formIsOkay()
    }
    
    func modify(coordinator: UJCoordinator) -> Bool {
        return self.model.addRegulationCheck(coordinator: coordinator)
    }
        
}

class PRegulationCheckStageDelegate  {
    var steps: [GenericRegulationView] = []
    var index: Int = 0
    
    init(config: ERP_Config, coordinator: UJCoordinator) {
        
    }
    
    func stillHaveSteps()  -> Bool {
        return index < steps.count
    }
    
    func formIsOkay() -> Bool {
        return steps[index].formIsOkay()
    }
    func modify(coordinator: UJCoordinator) -> Bool {
        return steps[index].modify(coordinator: coordinator)
    }
}

func navigateToNextStep(coordinator: UJCoordinator) -> GenericRegulationView {

//    if coordinator.stageDelegate == nil {
//        throw UJCoordinatorError.attributeNotSet(name: "Delegate")
//    }
//
//    if coordinator.stageDelegate?.index == nil {
//        throw UJCoordinatorError.attributeNotSet(name: "Index")
//    }
//
//
//    if coordinator.stageDelegate?.steps == nil {
//        throw UJCoordinatorError.attributeNotSet(name: "Steps")
//    }

    coordinator.stageDelegate?.index += 1

    // change delegate
    if !coordinator.stageDelegate!.stillHaveSteps() {
        coordinator.changeDelegate()
    }

    let idx = coordinator.stageDelegate?.index

    return coordinator.stageDelegate!.steps[idx!]
}
