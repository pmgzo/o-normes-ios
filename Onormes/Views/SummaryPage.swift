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
        "rampe": "ramp",
        "préétape": "Ruler",
        "alléestructurante" : "Ruler",
        "alléenonstructurante": "Ruler",
        "escalier" : "Stairs",
        "ascenseur" : "Elevator",
        "filedattente" : "waitingLine",
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
    // summary page
    var summaryPage: some View {
        VStack {
                Text("Resumé de l'audit").font(.system(size: 20.0))
                Spacer()
                       .frame(height: 30)
            
                Text("New Page !")
                
                DataNormList(list: self.coordinator!.dataAudit)
                
                QuitingNavigationLink(isActive: $isActive) {
                    if appState.offlineModeActivated == false {
                        Button(action: {
                            Task {
                                do {
                                    animateCircle = true
                                    
                                    let res = try await APIService().createAudit(name: self.coordinator!.auditRef, location: "Paris, Ile de France", comment: "Test", owner_phone: "pas d'info", owner_email: UserDefaults.standard.string(forKey: "email") ?? "")
                                    
                                    APIService().sendAllDataAudit(auditId: res, data: self.coordinator!.dataAudit)
                                    
                                    print("End sending information")
                                    
                                    animateCircle = false
                                    self.isActive = true
                                } catch {
                                    // TODO: to fix warning (line above)
                                    print(error)
                                }
                            }
                        }){
                            if animateCircle {
                                LoadingCircle()
                            } else {
                                Text("Valider et Envoyer")
                            }
                            
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

struct SummaryWrapper: View {
    
    var coordinator: UJCoordinator
    var content: () -> GenericRegulationView
    @State var selectionTag: String? = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    
    init(coordinator: UJCoordinator, content: @escaping () -> GenericRegulationView) {
        print("create summary")
        self.coordinator = coordinator
        self.content = content
    }
    
    
    
    var body: some View {
        VStack {
            HStack {
                    Button("Retour") {
                        self.coordinator.backToThePreviousStage()
                        self.coordinator.userJourneyNotFinished()

                        presentationMode.wrappedValue.dismiss()
                    }.buttonStyle(ButtonStyle())
                
                Spacer().frame(width: 150)

                NavigationLink(
                    destination: SelectStageInSummaryView(coordinator: self.coordinator).navigationBarHidden(true),
                    tag: "stageSelection", selection: $selectionTag) {
                    Button(action: {
                        selectionTag = "stageSelection"
                    }) {
                        Image(systemName: "plus").resizable().foregroundColor(.white).frame(width: 15, height: 15).padding()
                    }.background(Color(hue: 246/360, saturation: 0.44, brightness: 0.24, opacity: 1)).cornerRadius(13).frame(width: 16, height: 16).padding()
                }
            }
            Spacer().frame(height: 40)

            content()
        }
    }
}

