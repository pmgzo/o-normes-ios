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

//TODO: faire une map de norme à verifier qui contient, l'image specific à check étape (porte, escalier, allée structurante/non structurante)
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid-using-lazyvgrid-and-lazyhgrid

/**
 This is an extension of the class **GenericRegulationView**. It defines the **RegulationsSelection** page.
 
 */

extension GenericRegulationView {
    
    var regulationsPage: some View {
        VStack {
            HStack {
                Button("Retour") {
                    // coordinator check
                    self.navcoordinator?.renderStepPage = false
                }.buttonStyle(ButtonStyle())
                Spacer().frame(width: 250)
            }
            Spacer()
                   .frame(height: 40)
            Text("Ajoutez une étape au parcours utilisateur").font(.system(size: 20.0))
            Spacer()
                   .frame(height: 30)
            ScrollView {
                LazyVGrid(columns: gridItemLayout, alignment: .center, spacing: 20) {
                    ForEach(0..<regulationPageslist.count, id: \.self) { i in
                        Button(regulationPageslist[i].name) {
                            regulationPageslist[i].selected = !regulationPageslist[i].selected
                            print(regulationPageslist[i].id + " selected")
                            if regulationPageslist[i].selected {
                                // add
                                if !selectedItems.contains(id: regulationPageslist[i].id) {
                                    self.selectedItems.addItem(id: regulationPageslist[i].id)
                                }
                            } else {
                                // remove
                                self.selectedItems.removeItem(id: regulationPageslist[i].id)
                            }
                        }.foregroundColor(regulationPageslist[i].selected ? .black : .gray)
                    }
                }.padding(.horizontal)
            }.frame(maxWidth: 550).background(Image("Logo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit).frame(width: 300).opacity(0.8))
            
            if selectedItems.items.count != 0 {
                HStack {
                    Button("Valider") {
                        print(selectedItems.items)
                        coordinator!.addRegulationCheckStages(ids: selectedItems.items)

                        //reset values
                        self.selectedItems.items = Set<String>()
                        for (index, _) in regulationPageslist.enumerated() {
                            regulationPageslist[index].selected = false
                        }
                        
                        navcoordinator?.renderStepPage = false
                    }.buttonStyle(validateButtonStyle())
                    Spacer().frame(maxWidth: 40)
                    Button("Annuler") {
                        // empty list
                        selectedItems.items = Set<String>()
                    }.buttonStyle(deleteButtonStyle())
                }
            } else {
                Spacer().frame(height: 64)
            }
        }
    }
}

