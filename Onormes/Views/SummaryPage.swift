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
    var data: NSDictionary;

    init(data: NSDictionary) {
        self.data = data
    }
    
    var body: some View {
        // details about the stage
        VStack {
            ForEach(0...(data.count), id: \.self) { i in
                HStack {
                    Text(data.allKeys[i] as! String)
                    Spacer()
                    if (data.allKeys[i] is Bool) {
                            Text((data[data.allKeys[i]] != nil) == true ? "Oui" : "Non")
                    } else {
                        Text(data[data.allKeys[i]] as! String)
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
            
            // TODO: validation button
            Button("Valider et Envoyer") {
                // send requests
                // TODO: Loading button once we're sending the infos
                
                // TODO: create json file in local also, with the audit's name
                // back to the menu
            }.buttonStyle(validateButtonStyle())
        }
    }
}

// FOR TESTING

var coo = UJCoordinator()

func instanciateUJCoo() -> UJCoordinator {
    coo.addNewRegulationCheck(newObject: NSDictionary(dictionary: ["est ce que pm c'est bogoss ?": "oui"]), newKey: "rampe d'entrée")
    return coo
}

struct Summary_Previews: PreviewProvider {
    
    //var coo = UJCoordinator()
    
    init() {
        coo.addNewRegulationCheck(newObject: NSDictionary(dictionary: ["est ce que pm c'est bogoss ?": "oui"]), newKey: "rampe d'entrée")
    }
    
    static var previews: some View {
        GenericRegulationView(coordinator: instanciateUJCoo())
    }
}

