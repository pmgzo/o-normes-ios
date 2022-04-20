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
    RegulationPageItem(id: "porte d'entrée2", imageName: "doorImage"),
    RegulationPageItem(id: "porte d'entrée3", imageName: "doorImage"),
    RegulationPageItem(id: "porte d'entrée4", imageName: "doorImage"),
    RegulationPageItem(id: "porte d'entrée5", imageName: "doorImage"),
    RegulationPageItem(id: "porte d'entrée6", imageName: "doorImage")
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

// Page to add Stages
struct AccessibilityRegulationsPage: PRegulationCheckView {
    //TODO: update navigation here
    @State private var selectionTag: String?;
//    private unowned let coordinator: CustomNavCoordinator;
//
    var navcoordinator: CustomNavCoordinator;
    var coordinator: UJCoordinator;
    @ObservedObject var selectedItems: SelectedRegulationSet;
    
    init(coordinator: UJCoordinator, navcoordinator: CustomNavCoordinator) {
        self.navcoordinator = navcoordinator
        self.coordinator = coordinator
        self.selectedItems = SelectedRegulationSet()
    }
    
    // we only have the door view for now
    private var gridItemLayout = [GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86)), GridItem(.fixed(86))]
    
    var body: some View {
        VStack {
            HStack {
                Button("Retour") {
                    // coordinator check
                    self.navcoordinator.renderStepPage = false
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
                        //TODO: add coordinator feature here
                        
                        //
                        selectedItems.items = Set<String>()
                        navcoordinator.renderStepPage = false
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
    
    func check() -> Bool {
        return true
    }
    
    func modify() -> Bool {
        return true
    }
}

struct AccessibilityRegulationsPage_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            AccessibilityRegulationsPage(coordinator: UJCoordinator(), navcoordinator: CustomNavCoordinator())
        }
      }
  }

