//
//  GenericRegulationView.swift
//  Onormes
//
//  Created by gonzalo on 06/08/2022.
//

import Foundation
import SwiftUI

class StageDescription: ObservableObject {
    @Published var value: String = ""
}

/**
 This class is the main view of the user journey navigation. It handles the summary page, the regulations selection page, and substeps pages.
 
 **Properties**
 
- General properties:
    - navcoordinator: handle substep and regulations selections page.
    - coordinator: user journey coordinator
    - selectionTag: tags to handle event for navigation buttons
- Regulations Selection properties:
    - selectedItems:  selected stages
    - gridItemLayout: grid for the regulations selection
- SubSteps properties:
    - title: top title name
    - content: list of the forms in the current substeps
    - substep: current substep id
    - dataContainer: forms's data
 
 **Constructors**
 
 - SubStep constructor:
 ```swift
 init(title: String, content: [RegulationCheckField], id: String, subStepId: String)
 ```
 - Regulations Selection constructor:
 ```swift
 init(coordinator: UJCoordinator, navcoordinator: CustomNavCoordinator)
 ```
 - Summary constructor:
 ```swift
 init(coordinator: UJCoordinator)
 ```
 
 */

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
    
    // selection step
    @ObservedObject var selectedItems: SelectedRegulationSet;
    var gridItemLayout: [GridItem];
    @State var isActive = false
    @State var animateCircle: Bool = false
    @State var stageList: [RegulationPageItem]
    
    // description
    @ObservedObject var description: StageDescription;
    
    @EnvironmentObject var appState: AppState

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
        //self.description = ""
        self.description = StageDescription()
        self.stageList = []
    }
    
    // for accessibility page
    init(coordinator: UJCoordinator, navcoordinator: CustomNavCoordinator) {
        self.navcoordinator = navcoordinator
        self.coordinator = coordinator
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        //self.description = ""
        self.description = StageDescription()
        //self.isRegulationsPage = true
        self.pageType = PageType.addStage
        self.gridItemLayout = [GridItem(.adaptive(minimum: 100))]
        // self.model = GenericRegulationViewModel(content: [], id:  "")
        self.title = ""
        self.content = []
        self.id = ""
        self.subStepId = ""
        self.dataContainer = DataNormContainer(content: [])
        self.stageList = returnArray(stageNames: coordinator.getStageNames)
    }
    
    // recap page
    init(coordinator: UJCoordinator) {
        self.coordinator = coordinator
        self.navcoordinator = nil
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        self.gridItemLayout = [GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86))]
        //self.description = ""
        self.description = StageDescription()
        self.pageType = PageType.summary
        self.title = ""
        self.content = []
        self.id = ""
        self.subStepId = ""
        self.gridItemLayout = []
        self.dataContainer = DataNormContainer(content: [])
        self.stageList = []
    }
    
    // description page
    init(coordinator: UJCoordinator, description: String) {
        self.coordinator = coordinator
        self.navcoordinator = nil
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        self.gridItemLayout = []
        //self.description = description
        self.description = StageDescription()
        
        self.pageType = PageType.description
        self.title = ""
        self.content = []
        self.id = ""
        self.subStepId = ""
        self.gridItemLayout = []
        self.dataContainer = DataNormContainer(content: [])
        self.stageList = []
        self.description.value = description
    }
        
    var body: some View {
        
        if self.pageType == PageType.addStage {
            self.regulationsPage
        }
        else if self.pageType == PageType.summary {
            self.summaryPage
        }
        else if self.pageType == PageType.description {
            Text("Description")
            TextField("Description", text: $description.value)
        } else {
            VStack {
                Text(self.title!).font(.title).multilineTextAlignment(.center)
                Form {
                    Spacer().frame(minHeight: 70, maxHeight: 130)
                        
                    List(self.content!) { c in
                        // Text($0.name)
                        // model.displayError() ?
                        
                        Section(header: Text(c.type != TypeField.bool ? c.text :  "").foregroundColor(.black).multilineTextAlignment(.center), footer: Text("*champs obligatoire").foregroundColor(.red)) {
                                // TODO: add check box condition or text
                            if c.type == TypeField.bool {
                                Toggle(c.text, isOn: self.booleanBinding(for: c))
                            }
                            else if c.type == TypeField.category {
                                // drop down menu
                                DropDownMenu(labelList: c.menusCategories, text: self.bindingCategory(for : c,  categories: c.menusCategories))//.frame(height: 220)
                            }
                            else {
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
    
    func getDescription() -> String {
        return self.description.value
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
                return self.dataContainer.data[key]!.valueString
            },
            set: {
                self.dataContainer.data[key]!.valueString = $0
            })
    }
    
    func bindingCategory(for field: RegulationCheckField, comment: Bool = false, categories: [String]) -> Binding<String> {
        var key = field.key
        if comment {
            key += "-comment"
        }
        return .init(
            get: {
                if self.dataContainer.data[key] == nil {
                    return ""
                }
                return self.dataContainer.data[key]!.valueString
            },
            set: {
                self.dataContainer.data[key]!.valueString = $0
            })
    }
    
    func booleanBinding(for field: RegulationCheckField) -> Binding<Bool> {
        return .init(
            get: { self.dataContainer.data[field.key]!.valueCheckBox},
            set: { self.dataContainer.data[field.key]!.valueCheckBox = $0})
    }

    
    func formIsOkay() -> Bool {
        // return true
        return self.model.formIsOkay(data: self.dataContainer.data)
    }
    
    /**
     This function acts as a bridge to access the **GenericRegulationViewModel** and ask to save the data (usually after clicking on the next button.
     
    - Parameters:
        - coordinator: user journey coordinator (used to change the data)
     */
    
    func modify(coordinator: UJCoordinator) -> Bool {
        return self.model.addRegulationCheck(coordinator: coordinator, data: self.dataContainer.data, content: self.content!, subStepId: self.subStepId!)
    }
    
    /**
     This function reload the view and the data written. This function is called if the user decide to going back, and change some data.
    - Parameters:
     - savedData: saved data to be reloaded
     */
    func reloadSavedData(savedData: DataNorm) {
        for value in savedData.data {
            if value.type == TypeField.bool {
                dataContainer.data[value.key]?.valueCheckBox = value.valueCheckBox
            } else {
                dataContainer.data[value.key]?.valueString = value.valueString
            }
            //dataContainer.data[value.key]?.comment = value.comment
        }
    }
}
