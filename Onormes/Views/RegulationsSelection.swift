//
//  RegulationsSelection.swift
//  Onormes
//
//  Created by gonzalo on 19/04/2022.
//

import Foundation
import SwiftUI

/**
 This structure is used in the **RegulationSelection** page.
 Enables us to identify which items has been selected by the user.
 
 */

struct RegulationPageItem {
    let id: String // for navigation but i think we will delete navigation
    let name: String
    let imageName: String
    var selected: Bool = false
}

/**
 
 This global variable is used in the **RegulationSelection** page. Usually when we add a new stage in the app, we have to add it in this global variable as well.
 
 */

var regulationPageslist: [RegulationPageItem] = [
    // TODO: to move within the class (GenericRegulationView)
    RegulationPageItem(id: "portedentrée", name: "porte d'entrée", imageName: "doorImage"),
    RegulationPageItem(id: "rampe", name: "rampe d'entrée", imageName: "doorImage"),
    RegulationPageItem(id: "alléestructurante", name: "allée structurante", imageName: "doorImage"),
    RegulationPageItem(id: "alléenonstructurante", name: "allée non structurante", imageName: "doorImage"),
    RegulationPageItem(id: "escalier", name: "escalier", imageName: "doorImage"),
    RegulationPageItem(id: "ascenseur", name: "ascenseur", imageName: "doorImage"),
    RegulationPageItem(id: "filedattente", name: "file d'attente", imageName: "doorImage"),
    RegulationPageItem(id: "cheminementexterieur", name: "cheminement exterieur", imageName: "doorImage"),
    RegulationPageItem(id: "parking", name: "parking", imageName: "doorImage"),
]

/**
 
 Function to match string patter
 
 */

func match(string: String, patternValue: String) -> Bool {
    let range = NSRange(location: 0, length: string.utf16.count)
    let pattern  = patternValue
    let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
    
    return regex.firstMatch(in: string, options: [], range: range) != nil
}

/**
 This is a custom ObservableObject to handle item selection in the **RegulationSelection** page.
 
 */

class SelectedRegulationSet: ObservableObject {
    @Published var items: Set<String>;
    
    init(selectedItems: Set<String> = []) {
        self.items = selectedItems
    }
    
    func addItem(id: String) {
        items.insert(id)
    }
    func removeItem(id: String) {
        items.remove(id)
    }
    
    func contains(id: String) -> Bool {
        return items.contains(id)
    }
}

// TODO: faire une map de norme à verifier qui contient, l'image specific à check étape (porte, escalier, allée structurante/non structurante)
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid-using-lazyvgrid-and-lazyhgrid

/**
 This is an extension of the class **GenericRegulationView**. It defines the **RegulationsSelection** page.

 */

extension GenericRegulationView {
    
    var regulationsPage: some View {
        VStack {
            HStack {
                Button("Retour") {
                    self.navcoordinator?.renderStepPage = .regular
                }.modifier(SecondaryButtonStyle1(size: 100))
                Spacer().frame(width: 250)
            }
            Spacer()
                   .frame(height: 40)
            Text("Ajoutez une étape au parcours utilisateur").modifier(Header2(alignment: .center))
            Spacer()
                   .frame(height: 30)
            ResearchBar(text: $fetchingKeyword)
            ScrollView {
                ForEach(searchResult, id: \.self) { i in
                    Button(action: {
                        self.stageList[i].selected = !stageList[i].selected
                        
                        if stageList[i].selected {
                            // add
                            if !selectedItems.contains(id: stageList[i].id) {
                                self.selectedItems.addItem(id: stageList[i].id)
                            }
                        } else {
                            // remove
                            self.selectedItems.removeItem(id: stageList[i].id)
                        }
                    },label : {
                        VStack {
                            HStack {
                                HStack {
                                    Text(stageList[i].name).multilineTextAlignment(.leading)
                                }.frame(width: (UIScreen.screenWidth - 100) / 3 * 2, alignment: .leading)
                                
                                HStack {
                                    CheckBox(filled: stageList[i].selected)
                                }.frame(width:  (UIScreen.screenWidth - 100) / 3,
                                    alignment: .trailing)
                            }
                            .frame(maxWidth: .infinity)
                            Divider()
                        }.frame(height: 70)
                    })
                }
            }.frame(maxWidth: .infinity).background(.white)
            
            if selectedItems.items.count != 0 {
                VStack {
                    Button("Valider") {

                        coordinator!.addRegulationCheckStages(ids: selectedItems.items)

                        //reset values
                        self.selectedItems.items = Set<String>()
                        for (index, _) in stageList.enumerated() {
                            stageList[index].selected = false
                        }

                        navcoordinator?.renderStepPage = .regular
                    }
                    .modifier(PrimaryButtonStyle1())
                    .transition(.slide)

                    Spacer().frame(height: 10)
                    
                    Button("Annuler") {
                        // empty list
                        selectedItems.items = Set<String>()
                    }.modifier(SecondaryButtonStyle1())
                    Spacer().frame(height: 20)
                }
            } else {
                Spacer().frame(height: 10)
            }
        }
    }
    
    var searchResult: [Int] {
        if self.fetchingKeyword == "" {
            return Array(0..<stageList.count)
        } else {
            var array: [Int] = []
            for i in 0..<self.stageList.count {
                if match(string: self.stageList[i].name, patternValue: self.fetchingKeyword) {
                    array.append(i)
                }
            }
            return array
        }
    }
}


func returnArray(stageNames: [String]) -> [RegulationPageItem] {
    var array: [RegulationPageItem]  = []
    for key in stageNames {
        array.append(RegulationPageItem(id: key, name: key, imageName: "doorImage"))
    }
    return array
}

/**
 Page to select step during the user journey
 
 */

struct SelectStageView: View {
    @ObservedObject var selectedItems: SelectedRegulationSet;
    
    @State var userJourneyStarted = false
    
    var gridItemLayout: [GridItem];
    var coordinator: UJCoordinator;
    @State var stageList: [RegulationPageItem];
    
    @State var fetchingKeyword: String = "";

    init(coordinator: UJCoordinator) {
        self.coordinator = coordinator
        self.gridItemLayout = [GridItem(.adaptive(minimum: 100))]
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        
        // as it is a state we should give it all the data during initialization
        self.stageList = returnArray(stageNames: self.coordinator.getStageNames)
    }
    
    
    
    var body: some View {
        ReturnButtonWrapper {
            VStack {
                Text("Ajoutez au minimum une étape pour commencer le parcours").font(.system(size: 20.0))
                Spacer()
                       .frame(height: 30)
                ResearchBar(text: $fetchingKeyword)
                    ScrollView {
                        ForEach(searchResult, id: \.self) { i in
                            Button(action: {
                                self.stageList[i].selected = !stageList[i].selected
                                
                                if stageList[i].selected {
                                    // add
                                    if !selectedItems.contains(id: stageList[i].id) {
                                        self.selectedItems.addItem(id: stageList[i].id)
                                    }
                                } else {
                                    // remove
                                    self.selectedItems.removeItem(id: stageList[i].id)
                                }
                            },label : {
                                VStack {
                                    HStack {
                                        HStack {
                                            Text(stageList[i].name).multilineTextAlignment(.leading)
                                        }.frame(width: (UIScreen.screenWidth - 100) / 3 * 2, alignment: .leading)
                                        
                                        HStack {
                                            CheckBox(filled: stageList[i].selected)
                                        }.frame(width:  (UIScreen.screenWidth - 100) / 3,
                                            alignment: .trailing)
                                    }
                                    .frame(maxWidth: .infinity)
                                    Divider()
                                }.frame(height: 70)
                            })
                        }
                    }.frame(maxWidth: .infinity, maxHeight: .infinity).background(.white)
                

                if selectedItems.items.count != 0 || userJourneyStarted == true { // its a hack to allow the navigation to continue otherwise it stops as we reset selectedItems
                    VStack {
                        CustomNavigationLink(
                            coordinator: self.coordinator,
                            isActive: $userJourneyStarted,
                            destination: { () -> GenericRegulationView
                                in return self.coordinator.getNextView()
                            },
                            label: {
                                Button("Valider") {
                                    self.coordinator.addRegulationCheckStages(ids: selectedItems.items)

                                    self.coordinator.nextStep(start: true)

                                    userJourneyStarted = true
                                    
                                    //reset values
                                    for (index, _) in stageList.enumerated() {
                                        stageList[index].selected = false
                                    }
                                    self.selectedItems.items = Set<String>()
                                    
                                }
                        }).modifier(PrimaryButtonStyle1())
                        Spacer().frame(height: 10)
                        Button("Annuler") {
                            selectedItems.items = Set<String>()
                        }.modifier(SecondaryButtonStyle1())
                        Spacer().frame(height: 20)
                    }
                } else {
                    Spacer().frame(height: 10)
                }
            }
        }
    }
    
    var searchResult: [Int] {
        if self.fetchingKeyword == "" {
            return Array(0..<stageList.count)
        } else {
            var array: [Int] = []
            for i in 0..<self.stageList.count {
                if match(string: self.stageList[i].name, patternValue: self.fetchingKeyword) {
                    array.append(i)
                }
            }
            return array
        }
    }
    
}

// Stage Selection in summary page

struct SelectStageInSummaryView: View {
    @ObservedObject var selectedItems: SelectedRegulationSet;
    
    @State var stageSelected = false
    
    var gridItemLayout: [GridItem];
    var coordinator: UJCoordinator;
        
    @State var stageList: [RegulationPageItem];
    
    @State var fetchingKeyword: String = "";
    
    init(coordinator: UJCoordinator) {
        self.coordinator = coordinator
        self.gridItemLayout = [GridItem(.adaptive(minimum: 100))]
        self.selectedItems = SelectedRegulationSet(selectedItems: [])
        self.stageList = returnArray(stageNames: self.coordinator.getStageNames)
        
    }
    
    
    
    var body: some View {
        ReturnButtonWrapper {
            VStack {
                Text("Ajoutez au minimum une étape pour commencer le parcours").font(.system(size: 20.0))
                Spacer()
                       .frame(height: 30)
                ResearchBar(text: $fetchingKeyword)
                ScrollView {
                    ForEach(searchResult, id: \.self) { i in
                        Button(action: {
                                self.stageList[i].selected = !stageList[i].selected
                                if stageList[i].selected {
                                    // add
                                    if !selectedItems.contains(id: stageList[i].id) {
                                        self.selectedItems.addItem(id: stageList[i].id)
                                    }
                                } else {
                                    // remove
                                    self.selectedItems.removeItem(id: stageList[i].id)
                                }
                        }, label: {
                            VStack {
                                HStack {
                                    HStack {
                                        Text(stageList[i].name).multilineTextAlignment(.leading)
                                    }.frame(width: (UIScreen.screenWidth - 100) / 3 * 2, alignment: .leading)
                                    
                                    HStack {
                                        CheckBox(filled: stageList[i].selected)
                                    }.frame(width:  (UIScreen.screenWidth - 100) / 3,
                                        alignment: .trailing)
                                }
                                .frame(maxWidth: .infinity)
                                Divider()
                            }.frame(height: 70)
                        })
                    }
                }.frame(maxWidth: .infinity).background(.white)
                

                if selectedItems.items.count != 0 || stageSelected == true { // its a hack to allow the navigation to continue otherwise it stops as we reset selectedItems
                    VStack {
                        CustomNavigationLink(
                            coordinator: self.coordinator,
                            isActive: $stageSelected,
                            destination: { () -> GenericRegulationView in return self.coordinator.getNextView()
                            },
                            label: {
                                Button("Valider") {
                                    self.coordinator.addRegulationCheckStages(ids: selectedItems.items)

                                    stageSelected = true
                                    
                                    //reset values
                                    for (index, _) in stageList.enumerated() {
                                        stageList[index].selected = false
                                    }
                                    self.selectedItems.items = Set<String>()
                                    
                                }
                        }).modifier(PrimaryButtonStyle1())
                        Spacer().frame(height: 10)
                        Button("Annuler") {
                            selectedItems.items = Set<String>()
                        }.modifier(SecondaryButtonStyle1())
                        Spacer().frame(height: 20)
                    }
                } else {
                    Spacer().frame(height: 10)
                }
            }
        }
    }

    var searchResult: [Int] {
        if self.fetchingKeyword == "" {
            return Array(0..<stageList.count)
        } else {
            var array: [Int] = []
            for i in 0..<self.stageList.count {
                if match(string: self.stageList[i].name, patternValue: self.fetchingKeyword) {
                    array.append(i)
                }
            }
            return array
        }
    }
}
