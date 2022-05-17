//
//  SummaryPage.swift
//  Onormes
//
//  Created by gonzalo on 13/05/2022.
//

import Foundation
import SwiftUI

func getImageName(id: String) -> String {
    let stageMap: [String:String] = [
        "porte d'entrée" : "Door",
        "rampe d'entrée" : "Ramp",
        "allée structurante" : "Ruler",
        "allée non structurante": "Ruler",
        "escalier" : "Stairs",
        "ascenseur" : "Elevator",
        "file d'attente" : "WaitingLine"
    ]
    return stageMap[id]!
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
            ForEach(0...(data.count), id: \.self) { i in
                HStack {
                    Text(data[i].key)
                    Spacer()
                    if (data[i].type == TypeField.bool) {
                        Text((data[i].valueCheckBox == true ? "Oui" : "Non"))
                    } else {
                        Text(data[i].valueMetric)
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
        ScrollView {
            List(self.list, id: \.id) { norm in
                Text("Ici")
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
                    presentationMode.wrappedValue.dismiss()
                }.buttonStyle(ButtonStyle())
                Spacer().frame(width: 250)
            }
            Spacer()
                   .frame(height: 40)
            Text("Resumé de l'audit").font(.system(size: 20.0))
            Spacer()
                   .frame(height: 30)
            // have to be an array of objects
            
            DataNormList(list: self.coordinator!.dataAudit)
            
            NavigationLink(
                destination:HomeMenu()) {
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

// FOR TESTING

// TODO: remove

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

