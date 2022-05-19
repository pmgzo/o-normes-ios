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

func parseNormId(_ rawId: String) -> String {
    let index = rawId.count - (36 + 1)
    return String(rawId[0..<index])
}

func getImageName(id: String) -> String {
    print("fetch id")

    let newId = parseNormId(id)
    print(newId)
    let stageMap: [String:String] = [
        "portedentrée" : "Door",
        "rampe": "Ramp",
        "alléestructurante" : "Ruler",
        "alléenonstructurante": "Ruler",
        "escalier" : "Stairs",
        "ascenseur" : "Elevator",
        "filedattente" : "WaitingLine"
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
        print("count")
        print(data.count)
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
                        Text(value.valueMetric == "" ? "vide" :  value.valueMetric)
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
                Button("Retour") {
                    self.coordinator!.backToThePreviousStage()
                    presentationMode.wrappedValue.dismiss()
                }.buttonStyle(ButtonStyle())
                Spacer().frame(width: 250)
            }
            Spacer()
                   .frame(height: 40)
            Text("Resumé de l'audit").font(.system(size: 20.0))
            Spacer()
                   .frame(height: 30)
            
            DataNormList(list: self.coordinator!.dataAudit)
            
            NavigationLink(
                destination: ContentView().navigationBarBackButtonHidden(true),
                tag: "backToTheMenu",
                selection: $selectionTag) {
                    Button("Valider et Envoyer") {
                    // send requests
                    // TODO: Loading button once we're sending the infos
                    print("Start sending information")
                    
                    let res = APIService().createAudit(name: self.coordinator!.auditRef, location: "Paris, Ile de France", comment: "Test", owner_phone: "pas d'info", owner_email: "pas d'info")
                    
                    sendAllDataAudit(auditId: res, data: self.coordinator!.dataAudit)
                    
                    print("End sending information")
                    
                    self.selectionTag = "backToTheMenu"
                    
                    // TODO: create json file in local also, with the audit's name
                    // back to the menu
                }.buttonStyle(validateButtonStyle()).navigationBarHidden(true)
                // TODO: validation button
                
            }
        }
    }
}

// TODO: remove

// FOR TESTING

//var coo = UJCoordinator()
//func instanciateUJCoo() -> UJCoordinator {
//    coo.addNewRegulationCheck(newObject: NSDictionary(dictionary: ["est ce que pm c'est bogoss ?": "oui"]), newKey: "rampe d'entrée")
//    return coo
//}
//
//struct Summary_Previews: PreviewProvider {
//
//    //var coo = UJCoordinator()
//
//    init() {
//        coo.addNewRegulationCheck(newObject: NSDictionary(dictionary: ["est ce que pm c'est bogoss ?": "oui"]), newKey: "rampe d'entrée")
//    }
//
//    static var previews: some View {
//        GenericRegulationView(coordinator: instanciateUJCoo())
//    }
//}

