//
//  AccessibilityRegulationPage.swift
//  Onormes
//
//  Created by gonzalo on 19/04/2022.
//

import Foundation
import SwiftUI

struct RegulationPageItem {
    let id: String // for navigation but i think we will delete navigation
    let imageName: String
    var selected: Bool = false
}

var regulationPageslist: [RegulationPageItem] = [
    RegulationPageItem(id: "porte d'entrée", imageName: "doorImage"),
    RegulationPageItem(id: "rampe d'entrée", imageName: "doorImage"),
    RegulationPageItem(id: "allée structurante", imageName: "doorImage"),
    RegulationPageItem(id: "allée non structurante", imageName: "doorImage"),
    RegulationPageItem(id: "escalier", imageName: "doorImage"),
    RegulationPageItem(id: "ascenseur", imageName: "doorImage"),
    RegulationPageItem(id: "file d'attente", imageName: "doorImage")
]

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
}

//TODO: faire une map de norme à verifier qui contient, l'image specific à check étape (porte, escalier, allée structurante/non structurante)
// https://www.hackingwithswift.com/quick-start/swiftui/how-to-position-views-in-a-grid-using-lazyvgrid-and-lazyhgrid

// regulationPage implementation
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
                        Button(regulationPageslist[i].id) {
                            regulationPageslist[i].selected = !regulationPageslist[i].selected
                            print(regulationPageslist[i].id + " selected")
                            if regulationPageslist[i].selected {
                                // add
                                self.selectedItems.addItem(id: regulationPageslist[i].id)
                            } else {
                                // remove
                                self.selectedItems.removeItem(id: regulationPageslist[i].id)

                            }
                        }.frame(width: 100).foregroundColor(regulationPageslist[i].selected ? .black : .gray)
                    }
                }.padding(.horizontal)
            }.frame(maxWidth: 350).background(Image("Logo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit).frame(width: 300).opacity(0.8))
            
            if selectedItems.items.count != 0 {
                HStack {
                    Button("Valider") {
                        coordinator!.addRegulationCheckStages(ids: selectedItems.items)
                        selectedItems.items = Set<String>()
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
            // add validation button
        }
    }
}
