//
//  SummaryPage.swift
//  Onormes
//
//  Created by gonzalo on 13/05/2022.
//

import Foundation
import SwiftUI

extension String {
    subscript (bounds: CountableClosedRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start...end])
    }

    subscript (bounds: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return String(self[start..<end])
    }
}
/**
 
 This function remove the uuid string from the id, and filter out only the stage's id
 
 - Parameters:
- rawId: id containing the uuid string whithin it
 
 - Returns: return parsed id
 
 */

func parseNormId(_ rawId: String) -> String {
    let index = rawId.count - (36 + 1)
    return String(rawId[0..<index])
}

func getImageName(id: String) -> String {
    print(id)

    let newId = parseNormId(id)
    let stageMap: [String:String] = [
        "portedentrée" : "Door",
        "rampe": "Ramp",
        "préétape": "Ruler",
        "alléestructurante" : "Ruler",
        "alléenonstructurante": "Ruler",
        "escalier" : "Stairs",
        "ascenseur" : "Elevator",
        "filedattente" : "WaitingLine",
        "cheminementexterieur": "Ruler",
        "parking": "Ruler"
    ]
    return stageMap[newId]!
}

struct DataNormRow: View {
    let name: String;
    let image: Image;
    
    init(stageName: String) {
        self.name = stageName
        self.image = Image(getImageName(id: stageName))
    }
    
    var body: some View {
        HStack {
            self.image
                .resizable()
                .frame(width: 50, height: 50)
            Text(name)

            Spacer()
        }
    }
}

struct DataNormDetails: View {
    var data: [RegulationNorm];

    init(data: [RegulationNorm]) {
        self.data = data
    }
    
    var body: some View {
        // details about the stage
        VStack {
            List(self.data) { value in
                HStack {
                    Text(value.key)
                    Spacer()
                    if (value.type == TypeField.bool) {
                        Text((value.valueCheckBox == true ? "Oui" : "Non"))
                    } else {
                        Text(value.valueString == "" ? "vide" :  value.valueString)
                    }
                }
            }
        }
    }
}

struct DataNormList: View {
    
    var list: [DataNorm];
    
    init(list: [DataNorm]) {
        self.list = list
    }
    
    var body: some View {
        VStack {
            List(self.list) { norm in
                NavigationLink {
                    DataNormDetails(data: norm.data)
                } label: {
                    DataNormRow(stageName: norm.key)
                }
            }
        }
    }
}

extension GenericRegulationView {
    // Summary page
    var summaryPage: some View {
        VStack {
                HStack {
                    CustomNavigationLink(coordinator: self.coordinator!, tag: "goback", selection: $selectionTag, destination: self.coordinator!.getPreviousView, navigationButton: true) {
                        Button("Retour") {
                            self.coordinator!.backToThePreviousStage()
                            selectionTag = "goback"
                        }.buttonStyle(ButtonStyle())
                    }
                    Spacer().frame(width: 250)
                }
                Spacer()
                       .frame(height: 40)
                Text("Resumé de l'audit").font(.system(size: 20.0))
                Spacer()
                       .frame(height: 30)
                
                DataNormList(list: self.coordinator!.dataAudit)
                
                QuitingNavigationLink(isActive: $isActive) {
                    if appState.offlineModeActivated == false {
                            Button("Valider et Envoyer") {
                            // TODO: Loading button once we're sending the infos
                            print("Start sending information")
                            Task {
                               do {
                                   let res = try await APIService().createAudit(name: self.coordinator!.auditRef, location: "Paris, Ile de France", comment: "Test", owner_phone: "pas d'info", owner_email: UserDefaults.standard.string(forKey: "email") ?? "")
                                   APIService().sendAllDataAudit(auditId: res, data: self.coordinator!.dataAudit)
                                   
                                   print("End sending information")
                                   self.isActive = true
                                   
                                   self.selectionTag = "backToTheMenu"
                               } catch {
                                   // TODO: to fix warning (line above)
                                   print(error)
                               }
                            }
                            print("End sending information")
                            // TODO: create json file in local also, with the audit's name
                        }.buttonStyle(validateButtonStyle())
                    } else {
                        Button("Enregistrer l'audit") {
                            self.isActive = true
                        }.buttonStyle(GrayButtonStyle())
                    }
            }
        }
    }
}
