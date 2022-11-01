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

func limitStringLength(str: String, limit: Int) -> String {
    if str.count > limit {
        return String(str[0..<limit]) + "..."
    }
    return str
}

struct DataDetails: View {
    let text: String;
    
    @State var value: Bool;
    @State var comment: String;
    var dataSaved: DataNorm

    init(data: DataNorm) {
        if data.data[0].key.contains("-comment") {
            comment = data.data[0].valueString
            value = data.data[1].valueCheckBox
        } else {
            comment = data.data[1].valueString
            value = data.data[0].valueCheckBox
        }
        text = data.subStepId
        dataSaved = data
    }
    
    var body: some View {
        VStack {
            // details about the stage
            Text(text).modifier(Header1())
            Spacer().frame(height: 100)
            HStack {
                Spacer().frame(width: 35)
                Text("Valeur").modifier(Header3())
            }.frame(maxWidth: .infinity, alignment: .leading)
            
            //Toggle("test", isOn: $value)
            HStack {
                BooleanRadioButtons(value: $value)
            }.frame(maxWidth: .infinity, alignment: .center)

            Spacer().frame(height: 50)

            HStack {
                Spacer().frame(width: 35)
                Text("Commentaire").modifier(Header3())
            }.frame(maxWidth: .infinity, alignment: .leading)
        
            Spacer().frame(height: 20)
            TextField("commentaire", text:$comment).textFieldStyle(CommentTextFieldStyle()).frame(width: 300)
        }.onDisappear(perform: {
            if dataSaved.data[0].key.contains("-comment") {
                dataSaved.data[0].valueString = comment
                dataSaved.data[1].valueCheckBox = value
            } else {
                dataSaved.data[1].valueString = comment
                dataSaved.data[0].valueCheckBox = value
            }
        })
    }
}

struct StageDetails: View {
    var data: [DataNorm];
    var stageName: String;

    init(stage: StageWrite) {
        data = stage.data
        stageName = stage.stageName
    }

    var body: some View {
        // details about the stage
        VStack {
            Text(stageName).modifier(Header1())
            Spacer().frame(height: 30)
            Text("Critères d'accessibilité").modifier(Header2())
            List(self.data) { value in
                HStack {
                    NavigationLink {
                        DataDetails(data: value)
                    } label: {
                        Text(limitStringLength(str: value.subStepId, limit: 20)).modifier(Header3())
                    }
                }
            }
        }
    }
}

struct StageRow: View {
    let name: String;
    let description: String;
    
    init(stageName: String, description: String) {
        self.name = stageName
        self.description = description
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(self.name).modifier(Header3())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            HStack {
                Text(limitStringLength(str: self.description == "" ? "-" :  self.description, limit: 20)).italic().modifier(DescriptionText())
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}


struct StageList: View {
    
    var list: [StageWrite];
    
    init(list: [StageWrite]) {
        self.list = list
    }
    
    var body: some View {
        VStack {
            List(self.list) { stage in
                NavigationLink {
                    StageDetails(stage: stage)
                } label: {
                    StageRow(stageName: stage.stageName, description: stage.description)
                }
            }
        }
    }
}

extension GenericRegulationView {
    // summary page
    var summaryPage: some View {
        VStack {
                Text("Page Résumé").modifier(Header1())
                Spacer()
                       .frame(height: 30)

                // TODO: voir les données de l'audit
            
                Text("Etapes").modifier(Header2())
                StageList(list: self.savedData)

                QuitingNavigationLink(isActive: $isActive) {
                    if appState.offlineModeActivated == false {
                        Button(action: {
                            Task {
                                do {
                                    animateCircle = true
                                    
                                    for i in savedData {
                                        for i2 in i.data {
                                            print(i2.data[0])
                                            print(i2.data[1])
                                        }
                                    }
//                                    let res = try await APIService().createAudit(name: self.coordinator!.auditRef, location: "Paris, Ile de France", comment: "Test", owner_phone: "pas d'info", owner_email: UserDefaults.standard.string(forKey: "email") ?? "")
// APIService().sendAllDataAudit(auditId: res, data: self.coordinator!.dataAudit)
//
//                                    print("End sending information")
                                    
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
                        // for offline mode
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

struct DataDetails_Previews: PreviewProvider {
  static var previews: some View {
      DataDetails(data:
            DataNorm(key: "test", data:
                [
                    RegulationNorm(key: "test2", inst: "Gare à proximité", type: TypeField.bool, mandatory: true, valueString: "", valueBool: true),

                    
                    RegulationNorm(key: "test1", inst: "Gare à proximité", type: TypeField.string, mandatory: true, valueString: "Pomme24", valueBool: false)
                ]
            , subStepId: "Trottoirs adaptés"))
  }
}
