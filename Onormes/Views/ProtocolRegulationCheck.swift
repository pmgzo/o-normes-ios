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
    let comment: String;
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
    func addRegulationCheck(coordinator: UJCoordinator, data: [String:RegulationNorm], content: [RegulationCheckField]) -> Bool
    func formIsOkay(data: [String:RegulationNorm]) -> Bool
}

class GenericRegulationViewModel: PRegulationCheckViewModel {
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
    
    
    func formIsOkay(data: [String:RegulationNorm]) -> Bool {
        // check mandatory field
        print("form is okay:")
        print(data)
        
        if mandatoryItems.isEmpty {
            return true
        }
        
        for (_, regname) in mandatoryItems.enumerated() {
            
            if data[regname]!.type != TypeField.bool &&  data[regname]!.valueMetric == "" {
                return false
            }
        }
        
        return true
    }

    func addRegulationCheck(coordinator: UJCoordinator, data: [String:RegulationNorm], content: [RegulationCheckField]) -> Bool {
        if formIsOkay(data: data) {
            var newObject = DataNorm(key: self.id, data: [])
            for (_, value) in data {
                newObject.data.append(value)
            }
            coordinator.addNewRegulationCheck(newObject: newObject, newKey: self.id)
            return true
        }
        return false
    }
    
    func displayError(data: [String:RegulationNorm]) -> Bool {
        // check mandatory field
        return !formIsOkay(data: data)
    }
}

class DataNormContainer: ObservableObject {
    @Published var data: [String:RegulationNorm] = [:]
    
    init(content: [RegulationCheckField]) {
        for (_, reg) in content.enumerated() {
            data[reg.key] = RegulationNorm(key: reg.key, inst: reg.text, type: reg.type, mandatory: reg.optional)
            let commentId = reg.key + "-comment";
            data[commentId] = RegulationNorm(key: commentId, inst: reg.text, type: TypeField.string, mandatory: reg.optional)
        }
    }
}

struct GenericRegulationView: View
{
    var model: GenericRegulationViewModel = GenericRegulationViewModel()

    let title: String?;
    let content: [RegulationCheckField]?;
    let id: String?;
    var pageType = PageType.regular;
    @ObservedObject var dataContainer: DataNormContainer;

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
        self.dataContainer = DataNormContainer(content: content)
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
        self.dataContainer = DataNormContainer(content: [])
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
        self.dataContainer = DataNormContainer(content: [])
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
                                Toggle(c.text, isOn: self.booleanBinding(for: c))
                            } else {
                                TextField("mesure", text: self.binding(for: c)).textFieldStyle(MeasureTextFieldStyle())
                            }
                                    
                            TextField("commentaire", text: self.binding(for: c, comment: true)).textFieldStyle(CommentTextFieldStyle())
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
    
    //func binding(for key: String) -> Binding<String> {
    func binding(for field: RegulationCheckField, comment: Bool = false) -> Binding<String> {
        var key = field.key
        if comment {
            key += "-comment"
        }
        return .init(
            get: {
                
                if self.dataContainer.data[key] == nil {
                    return ""
                }
                return self.dataContainer.data[key]!.valueMetric
            },
            set: {
                print("la valeur est")
                print(self.dataContainer.data[key]!.valueMetric)
                print($0)
                self.dataContainer.data[key]!.valueMetric = $0
                
            })
    }
    
    func booleanBinding(for field: RegulationCheckField) -> Binding<Bool> {
        return .init(
            get: { self.dataContainer.data[field.key, default:  RegulationNorm(key: field.key, inst: field.text, type: TypeField.bool,  mandatory: field.optional)].valueCheckBox},
            set: { self.dataContainer.data[field.key] = RegulationNorm(key: field.key, inst: field.text, type: TypeField.bool,  mandatory: field.optional, valueBool: $0) })
    }

    
    func formIsOkay() -> Bool {
        // return true
        return self.model.formIsOkay(data: self.dataContainer.data)
    }
    
    func modify(coordinator: UJCoordinator) -> Bool {
        //TODO: att byta
        return self.model.addRegulationCheck(coordinator: coordinator, data: self.dataContainer.data, content: self.content!)
        //modify the coordinator here
    }
        
}

class PRegulationCheckStageDelegate  {
    var steps: [GenericRegulationView] = []
    var index: Int = 0
    
    init(config: ERP_Config, coordinator: UJCoordinator) {
        print("pStageDelegate ctor")
        self.index = 0
    }
    
    func stillHaveSteps()  -> Bool {
        return index < steps.count
    }
    
    func formIsOkay() -> Bool {
        print("form is okay ")
        return steps[index].formIsOkay()
    }
    func modify(coordinator: UJCoordinator) -> Bool {
        // to modify it is conditional
        return steps[index].modify(coordinator: coordinator)
    }
}

func navigateToNextStep(coordinator: UJCoordinator, start: Bool = false) {
    
    print("go next step")
    if start == false {
        coordinator.stageDelegate?.index += 1
            coordinator.goToNextStage()
        if !coordinator.stageDelegate!.stillHaveSteps() {
            coordinator.changeDelegate()
        }

    }

}

