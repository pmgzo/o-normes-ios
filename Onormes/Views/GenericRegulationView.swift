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
    var savedData: [StageWrite] = []
    var auditInfos: AuditInfos?;
    @State var selectionTag: String?;
    
    // selection step
    @State var fetchingKeyword: String = ""
    @ObservedObject var selectedItems: SelectedRegulationSet;
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
        self.description = StageDescription()
        self.pageType = PageType.summary
        self.title = ""
        self.content = []
        self.id = ""
        self.subStepId = ""
        self.dataContainer = DataNormContainer(content: [])
        self.stageList = []
        self.savedData = coordinator.getSavedData
        self.auditInfos = coordinator.getAuditInfos()
    }
    
    // description page
    init(coordinator: UJCoordinator, description: String) {
        self.coordinator = coordinator
        self.navcoordinator = nil
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        //self.description = description
        self.description = StageDescription()
        
        self.pageType = PageType.description
        self.title = ""
        self.content = []
        self.id = ""
        self.subStepId = ""
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
            VStack {
                Text("Nouvelle étape: \(self.coordinator!.getCurrentStageId())").modifier(Header1())
                Spacer().frame(height: 100)
                HStack {
                    Spacer().frame(width: 35)
                    Text("Description").modifier(Header3())
                }.frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Spacer().frame(width: 35)
                    TextField("Ajoutez une description à cette étape", text: $description.value).textFieldStyle(CommentTextFieldStyle())
                        .frame(width: 300)
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            VStack {

                Text(self.title!).modifier(Header1())
                
                Spacer().frame(height: 100)

                HStack {
                    Spacer().frame(width: 35)
                    Text(self.content![0].text).modifier(Header3())
                }.frame(maxWidth: .infinity, alignment: .leading)
                
                
                
                if self.content![0].type == TypeField.bool {
                    HStack {
                        BooleanRadioButtons(value: self.booleanBinding(for: self.content![0]))
                    }.frame(maxWidth: .infinity, alignment: .center)
                }
                else if self.content![0].type == TypeField.category {
                    // drop down menu
                    DropDownMenu(labelList: self.content![0].menusCategories, text: self.bindingCategory(for : self.content![0],  categories: self.content![0].menusCategories))
                } else {
                    TextField("mesure", text: self.binding(for: self.content![0])).textFieldStyle(MeasureTextFieldStyle())
                }
                
                Spacer().frame(height: 20)
                       
                HStack {
                    Spacer().frame(width: 35)
                    TextField("commentaire", text: self.binding(for: self.content![0], comment: true)).textFieldStyle(CommentTextFieldStyle())
                        .frame(width: 300)
                }.frame(maxWidth: .infinity, alignment: .leading)
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

struct Criteria_Previews: PreviewProvider {
    
  static var previews: some View {
//      UserJourneyNavigationPage(
//        content: {() -> GenericRegulationView in
//      GenericRegulationView(title: "Parking accessible",
//                            content: [
//                                RegulationCheckField(key: "Boitier de commande d’accès au parking  accessible depuis la place du conducteur", type: TypeField.bool, text: "Boitier de commande d’accès au parking  accessible depuis la place du conducteur", optional: false)
//                            ],
//                            id: "Parking accessible",
//                            subStepId: "Boitier de commande d’accès au parking  accessible depuis la place du conducteur")
//      }, coordinator: UJCoordinator(), navigationButton: false)
      
      //GenericRegulationView(coordinator: returnCoordinator(), description: "description")
      GenericRegulationView(coordinator: returnCoordinator())
  }
}

func returnCoordinator() -> UJCoordinator {
    var coordinator = UJCoordinator()
    coordinator.loadBuildingTypeStages(stages: temporaryStageList)
    coordinator.addRegulationCheckStages(ids: Set<String>(["Trottoirs adaptés"]))
    coordinator.nextStep(start: true)
    return coordinator
}
