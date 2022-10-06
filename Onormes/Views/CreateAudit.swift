//
//  CreateAudit.swift
//  Onormes
//
//  Created by gonzalo on 05/10/2022.
//

import Foundation
import SwiftUI

struct AuditData {
    
}

struct CreateAuditView: View {
    
    @State private var buildingType: String = "";
    
    @State private var name: String = "";
    @State private var buildingName: String = "";
    @State private var address: String = "";
    @State private var email: String = "";
    @State private var phoneNumber: String = "";
    @State private var notes: String = "";
    
    @State private var hasOpenBuildingType: Bool = false;

    var coordinator: UJCoordinator?;
    
    init() {
        // create object
    }

    var body: some View {
        ScrollView(.vertical) {
            Text("Remplissez les données de l'audit").font(.title).multilineTextAlignment(.center)
            
            Spacer()
            
            VStack {
                HStack {
                    Text("Nom de l'audit")
                    Spacer()
                }
                TextField("", text: $name).textFieldStyle(MeasureTextFieldStyle())
            }.frame(width:300)

            VStack {
                HStack {
                    Text("Nom de l'établissement")
                    Spacer()
                }
                TextField("", text: $buildingName).textFieldStyle(MeasureTextFieldStyle())
            }.frame(width:300)
            
            NavigationLink(
                destination: BuildingTypeSelection(buildingType: $buildingType),
                isActive: $hasOpenBuildingType,
                label: {
                    Button(action: {
                        hasOpenBuildingType = true
                    }) {
                        Text(buildingType.isEmpty ? "Sélectionez un type d'établissement" : buildingType).underline()
                    }.buttonStyle(LinkStyle())
                }
            )

            VStack {
                HStack {
                    Text("Adresse de l'établissement")
                    Spacer()
                }
                TextField("", text: $address).textFieldStyle(MeasureTextFieldStyle())
            }.frame(width:300)
            
            VStack {
                HStack {
                    Text("Numéro de téléphone du responsable")
                    Spacer()
                }
                TextField("", text: $phoneNumber).textFieldStyle(MeasureTextFieldStyle())
            }.frame(width:300)

            VStack {
                HStack {
                    Text("Notes")
                    Spacer()
                }
                TextField("", text: $notes).textFieldStyle(CommentTextFieldStyle())
            }.frame(width:300)

            Spacer()
            
            // submit button
            if self.validate() {
                Button("Page suivante") {
                    print("green")
                    // call API
                    
                    

                    //APIService().sendFeedback(feedback: textInput)
                    //presentationMode.wrappedValue.dismiss()
                }.buttonStyle(validateButtonStyle())
            } else {
                Button("Page suivante"){
                    print("gray")
                    // do nothing
                }.buttonStyle(GrayButtonStyle())
                
            }
        }

    }
    
    func validate() -> Bool {
        
        
        
        if !buildingType.isEmpty && !name.isEmpty && !buildingName.isEmpty {
            print(buildingType)
            print("true")
            return true
        }
        print("false")
        return false
    }

    
}

