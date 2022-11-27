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

struct AuditSummaryView: View {
    @ObservedObject var auditInfos: AuditInfosObject;

    var refAudit: AuditInfos;
    let dateFormatter = DateFormatter()
    var coordinator: UJCoordinator;

    init(auditInfos: AuditInfos, coordinator: UJCoordinator) {
        self.auditInfos = AuditInfosObject(infos: auditInfos)
        self.refAudit = auditInfos

        dateFormatter.dateFormat = "dd/MM/YY"
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            ReturnButtonWrapper(action: {() -> Void in                 saveData()
            }) {
                ScrollView(.vertical) {
                    VStack {
                        
                        Text("Donnée enregistrées:").modifier(Header1())
                        
                        Spacer().frame(height: 100)
                        
                        VStack {
                            HStack {
                                Text("Nom de l'audit")
                                Spacer()
                            }
                            TextField("", text: $auditInfos.name).textFieldStyle(MeasureTextFieldStyle())
                        }.frame(width:300)
                        
                        VStack {
                            Spacer().frame(height: 10)
                            HStack {
                                Text("Audit crée le: \(dateFormatter.string(from: refAudit.date))")
                                Spacer()
                            }
                            Spacer().frame(height: 10)
                        }.frame(width:300)
                        
                        VStack {
                            HStack {
                                Text("Nom de l'établissement")
                                Spacer()
                            }
                            TextField("", text: $auditInfos.buildingName).textFieldStyle(MeasureTextFieldStyle())
                        }.frame(width:300)
                        
                        VStack {
                            Spacer().frame(height: 10)
                            HStack {
                                Text("Type d'établissement: \(auditInfos.buildingType)")
                                Spacer()
                            }
                            Spacer().frame(height: 10)
                        }.frame(width:300)
                        
                        VStack {
                            HStack {
                                Text("SIRET de l'entreprise")
                                Spacer()
                            }
                            TextField("", text: $auditInfos.siret).textFieldStyle(MeasureTextFieldStyle())
                        }.frame(width:300)
                        
                        VStack {
                            HStack {
                                Text("Adresse de l'établissement")
                                Spacer()
                            }
                            TextField("", text: $auditInfos.address).textFieldStyle(MeasureTextFieldStyle())
                        }.frame(width:300)
                        
                        VStack {
                            HStack {
                                Text("Numéro de téléphone du responsable")
                                Spacer()
                            }
                            TextField("", text: $auditInfos.phoneNumber).textFieldStyle(MeasureTextFieldStyle())
                        }.frame(width:300)
                        
                        VStack {
                            HStack {
                                Text("Notes")
                                Spacer()
                            }
                            TextField("", text: $auditInfos.notes).textFieldStyle(CommentTextFieldStyle())
                        }.frame(width:300)
                    }
                }
                Spacer().frame(height: 10)
            }
        }
    }
    
    func saveData() {
        self.refAudit.buildingType = self.auditInfos.buildingType
        self.refAudit.name = self.auditInfos.name
        self.refAudit.buildingName = self.auditInfos.buildingName
        self.refAudit.address = self.auditInfos.address
        self.refAudit.siret = self.auditInfos.siret
        self.refAudit.email = self.auditInfos.email
        self.refAudit.phoneNumber = self.auditInfos.phoneNumber
        self.refAudit.notes = self.auditInfos.notes
        self.refAudit.date = self.auditInfos.date
        
        self.coordinator.setAuditInfos(auditInfos: self.refAudit)
    }
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
        ReturnButtonWrapper {
            VStack {
                Text(text).modifier(Header1())
                Spacer().frame(height: 100)
                HStack {
                    Spacer().frame(width: 35)
                    Text("Valeur").modifier(Header3())
                }.frame(maxWidth: .infinity, alignment: .leading)
                
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
        ReturnButtonWrapper {
            VStack {
                Text(stageName).modifier(Header1())
                Spacer().frame(height: 30)
                Text("Critères d'accessibilité").modifier(Header2())
                List(self.data) { value in
                    HStack {
                        NavigationLink {
                            DataDetails(data: value).navigationBarHidden(true)
                        } label: {
                            Text(limitStringLength(str: value.subStepId, limit: 20)).modifier(Header3())
                        }
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
                    StageDetails(stage: stage).navigationBarHidden(true)
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
                NavigationLink(
                    destination: AuditSummaryView(auditInfos: self.auditInfos!, coordinator: self.coordinator!).navigationBarHidden(true),
                    tag: "auditInfos",
                    selection: $selectionTag,
                    label: {
                        Button(action: {
                            selectionTag = "auditInfos"
                        }) {
                            Text("Modifier les infos de l'audit").underline()
                        }.buttonStyle(LinkStyle())
                    }
                )
            
                Text("Etapes").modifier(Header2())
                StageList(list: self.savedData)

                QuitingNavigationLink(isActive: $isActive) {
                    if appState.offlineModeActivated == false {
                        Button(action: {
                            Task {
                                do {
                                    animateCircle = true
                                    
                                    let api = APIService()
                                    
                                    
                                    let auditInfos = self.coordinator!.getAuditInfos()
                                    let auditId = try await api.createAudit(auditInfos: auditInfos)
                                    
                                    for stage in savedData {
                                        let stepId = try await api.createStep(stage: stage, auditId: auditId)
                                        for subcriterion in stage.data {
                                            let id = try await api.createMeasure(subcriterion: subcriterion, stepId: stepId, auditId: auditId,  criterionId: stage.idCriterion)
                                        }
                                        print("criterion well created")
                                    }
                                    
                                    animateCircle = false
                                    self.isActive = true
                                } catch ServerErrorType.internalError(let reason) {
                                    animateCircle = false
                                    requestError = RequestError(errorDescription: reason)
                                    displayErrorMessage = true
                                    return
                                } catch {
                                    animateCircle = false
                                    requestError = RequestError(errorDescription: "Internal Error")
                                    displayErrorMessage = true
                                    return
                                }
                            }
                        }){
                            if animateCircle {
                                LoadingCircle()
                            } else {
                                Text("Valider et Envoyer")
                            }
                            
                        }
                        .modifier(PrimaryButtonStyle1())
                    } else {
                        // for offline mode
                        Button("Enregistrer l'audit") {
                            self.isActive = true
                        }.modifier(PrimaryButtonStyle1())
                    }
                }.alert(
                    isPresented: $displayErrorMessage, error: requestError,
                   actions: { errorObject in
                        Button("Ok") {
                            requestError = nil
                            displayErrorMessage = false
                        }
                    },
                    message: { errorObject
                    in
                        Text(errorObject.errorDescription)
                    }
                )
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
                
                if !coordinator.loadedAudit {
                    Button("Retour") {
                        self.coordinator.backToThePreviousStage()
                        self.coordinator.userJourneyNotFinished()
                        
                        // TODO: check if it works
                        self.coordinator.updateSavedData(modifiedData: self.content().savedData)

                        presentationMode.wrappedValue.dismiss()
                    }.modifier(SecondaryButtonStyle1(size: 100))
                    
                    Spacer().frame(width: 205)

                    NavigationLink(
                        destination: SelectStageInSummaryView(coordinator: self.coordinator).navigationBarHidden(true),
                        tag: "stageSelection", selection: $selectionTag) {
                                AddStageButton(action: {
                                    selectionTag = "stageSelection"
                                    // TODO: check if it works
                                    self.coordinator.updateSavedData(modifiedData: self.content().savedData)
                                })
                        }
                } else {
                    Button("Retour") {
                        presentationMode.wrappedValue.dismiss()
                    }.modifier(SecondaryButtonStyle1(size: 100))

                    Spacer().frame(width: 250)
                }
            }
            Spacer().frame(height: 40)

            content()
            
            Spacer().frame(height: 10)
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
