//
//  ProtcolRegulationCheck.swift
//  Onormes
//
//  Created by gonzalo on 11/04/2022.
//

// TODO: rename file into DataTypes

import Foundation
import SwiftUI

enum PageType {
    case regular
    case addStage
    case summary
}

enum ViewModelUserJouneyError: Error {
    case missedInitializedVariable
    case stageNotInitialized
}

struct ERP_Config {
    //TODO: see what check needs to be added
    let hasMultipleFloor: Bool = true
    let hasElevator: Bool = true // maybe not usefull
}

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
    func addRegulationCheck(coordinator: UJCoordinator, data: [String : Any], content: [RegulationCheckField]) -> Bool
    func formIsOkay(data: [String:Any]) -> Bool
}

class GenericRegulationViewModel: PRegulationCheckViewModel
{
    //@State var data: [String : String] = [:];
    var mandatoryItems: Set<String>;
    var id: String;

    init() {
        self.id = ""
        self.mandatoryItems = []
    }
    
    func changeState(id: String, content: [RegulationCheckField]) -> Void {
        self.id = id
        for (_, reg) in content.enumerated() {
            if !reg.optional {
                mandatoryItems.insert(reg.key)
            }
        }
    }
    
    func changeId(id: String) -> Void {
        self.id = id
    }

    
// https://forums.swift.org/t/swiftui-how-to-use-dictionary-as-binding/34967/2
    
    
    func formIsOkay(data: [String:Any]) -> Bool {
        // check mandatory field
        if mandatoryItems.isEmpty {
            return true
        }
        
        for (_, regname) in mandatoryItems.enumerated() {
            if (data[regname] as! String) == "" {
                return false
            }
            return true
        }
        
        return true
    }

    func addRegulationCheck(coordinator: UJCoordinator, data: [String : Any], content: [RegulationCheckField]) -> Bool {
        if formIsOkay(data: data) {
            coordinator.addNewRegulationCheck(newObject: data as NSDictionary, newKey: self.id)
            return true
        }
        return false;
    }
    
    func displayError(data: [String:String]) -> Bool {
        // check mandatory field
        return !formIsOkay(data: data)
    }
}

struct GenericRegulationView: View
{
    @StateObject var model: GenericRegulationViewModel = GenericRegulationViewModel()
    @State var data: [String : Any] = [:];
    
    let title: String?;
    let content: [RegulationCheckField]?;
    let id: String?;
    var pageType = PageType.regular;

    //associatedtype View
    //let regulationPageContent: View?;
    var navcoordinator: CustomNavCoordinator?;
    var coordinator: UJCoordinator?;
    @State var selectionTag: String?;
    @ObservedObject var selectedItems: SelectedRegulationSet;
    var gridItemLayout: [GridItem];
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>;
    
    init(title: String, content: [RegulationCheckField], id: String) {
        self.title = title
        self.content = content
        let new_id = id + "-" + UUID().uuidString
        self.id = new_id
        self.pageType = PageType.regular
        self.gridItemLayout = []
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        self.model.changeState(id: new_id, content: content)
    }
    
    // for accessibility page
    init(coordinator: UJCoordinator, navcoordinator: CustomNavCoordinator) {
        self.navcoordinator = navcoordinator
        self.coordinator = coordinator
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        
        //self.isRegulationsPage = true
        self.pageType = PageType.addStage
        self.gridItemLayout = [GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86))]
        // self.model = GenericRegulationViewModel(content: [], id:  "")
        self.title = "";
        self.content = [];
        self.id = "";
    }
    
    // recap page
    init(coordinator: UJCoordinator) {
        self.coordinator = coordinator
        self.navcoordinator = nil
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        self.gridItemLayout = [GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86))]
        
        self.pageType = PageType.summary
        self.title = "";
        self.content = [];
        self.id = "";
        self.gridItemLayout = []
    }
    
    var body: some View {
        
        if self.pageType == PageType.addStage {
            self.regulationsPage
        }
        else if self.pageType == PageType.summary {
            self.summaryPage
        } else {
            VStack {
                Text(self.title!).font(.title).multilineTextAlignment(.center)
                Form {
                    Spacer().frame(minHeight: 70, maxHeight: 130)
                        
                    List(self.content!) { c in
                            //Text($0.name)
                        // model.displayError() ?
                        
                        Section(header: Text(c.type != TypeField.bool ? c.text :  "").foregroundColor(.black).multilineTextAlignment(.center), footer: Text("*champs obligatoire").foregroundColor(.red)) {
                                // TODO: add check box condition or text
                            if c.type == TypeField.bool {
                                Toggle(c.text, isOn: self.booleanBinding(for: c.key))
                            } else {
                                TextField("mesure", text: self.binding(for: c.key)).textFieldStyle(MeasureTextFieldStyle())
                            }
                                    
                            TextField("commentaire", text: self.binding(for: c.comment!)).textFieldStyle(CommentTextFieldStyle())
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
    
    func binding(for key: String) -> Binding<String> {
        return .init(
            get: { self.data[key, default: ""] as! String },
                    set: { self.data[key] = $0 })
    }
    
    func booleanBinding(for key: String) -> Binding<Bool> {
        return .init(
            get: { self.data[key, default: false] as! Bool },
                    set: { self.data[key] = $0 })
    }

    
    func formIsOkay() -> Bool {
        return self.model.formIsOkay(data: self.data)
    }
    
    func modify(coordinator: UJCoordinator) -> Bool {
        //TODO: att byta
        return self.model.addRegulationCheck(coordinator: coordinator, data: self.data, content: self.content!)
        //modify the coordinator here
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
        // to modify it is conditional
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
    
    if (!coordinator.stillHaveStage()) {
        // redirect to recap page
        return GenericRegulationView(coordinator: coordinator)
    }

    // change delegate
    if !coordinator.stageDelegate!.stillHaveSteps() {
        coordinator.changeDelegate()
    }

    let idx = coordinator.stageDelegate?.index

    return coordinator.stageDelegate!.steps[idx!]
}

