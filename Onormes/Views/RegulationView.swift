//
//  RegulationView.swift
//  Onormes
//
//  Created by gonzalo on 11/07/2022.
//

import Foundation
import SwiftUI

protocol PRegulationCheckViewModel: ObservableObject, Identifiable {
    func addRegulationCheck(coordinator: UJCoordinator, data: [String:RegulationNorm], content: [RegulationCheckField], subStepId: String) -> Bool
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

    
    func formIsOkay(data: [String:RegulationNorm]) -> Bool {
        // check mandatory field

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

    func addRegulationCheck(coordinator: UJCoordinator, data: [String:RegulationNorm], content: [RegulationCheckField], subStepId: String) -> Bool {
        if formIsOkay(data: data) {
            // TODO: maybe to change because we need the key if we need to go back to the previous state
            var newObject = DataNorm(key: self.id, data: [], subStepId: subStepId)
            for (_, value) in data {
                newObject.data.append(value)
            }
            // TODO: to modify
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

struct GenericRegulationView: View
{
    var model: GenericRegulationViewModel = GenericRegulationViewModel()

    let title: String?;
    let content: [RegulationCheckField]?;
    let id: String?;
    var pageType = PageType.regular;
    let subStepId: String?;
    @ObservedObject var dataContainer: DataNormContainer;

    //associatedtype View
    //let regulationPageContent: View?;
    var navcoordinator: CustomNavCoordinator?;
    var coordinator: UJCoordinator?;
    @State var selectionTag: String?;
    @ObservedObject var selectedItems: SelectedRegulationSet;
    var gridItemLayout: [GridItem];
    @State var isActive = false
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>;
    
    init(title: String, content: [RegulationCheckField], id: String, subStepId: String) {
        self.title = title
        self.content = content
        self.subStepId = subStepId
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
        self.gridItemLayout = [GridItem(.adaptive(minimum: 100))]
        // self.model = GenericRegulationViewModel(content: [], id:  "")
        self.title = ""
        self.content = []
        self.id = ""
        self.subStepId = ""
        self.dataContainer = DataNormContainer(content: [])
    }
    
    // recap page
    init(coordinator: UJCoordinator) {
        self.coordinator = coordinator
        self.navcoordinator = nil
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        self.gridItemLayout = [GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86))]
        
        self.pageType = PageType.summary
        self.title = ""
        self.content = []
        self.id = ""
        self.subStepId = ""
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
        return self.model.addRegulationCheck(coordinator: coordinator, data: self.dataContainer.data, content: self.content!, subStepId: self.subStepId!)
    }
    
    func reloadSavedData(savedData: DataNorm) {
        for value in savedData.data {
            if value.type == TypeField.bool {
                dataContainer.data[value.key]?.valueCheckBox = value.valueCheckBox
            } else {
                dataContainer.data[value.key]?.valueMetric = value.valueMetric
            }
            dataContainer.data[value.key]?.comment = value.comment
        }
    }
}

