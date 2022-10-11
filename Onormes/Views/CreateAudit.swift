//
//  CreateAudit.swift
//  Onormes
//
//  Created by gonzalo on 05/10/2022.
//

import Foundation
import SwiftUI

struct CreateAuditView: View {
    
    @State private var buildingType: String = "";
    
    @State private var name: String = "";
    @State private var buildingName: String = "";
    @State private var address: String = "";
    @State private var email: String = "";
    @State private var phoneNumber: String = "";
    @State private var notes: String = "";
    
    @State private var hasOpenBuildingType: Bool = false;
    @State private var animateButton: Bool = false;
    
    @State private var startUserJourney: Bool = false

    var coordinator = UJCoordinator()

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
                //
                NavigationLink(
                    destination: SelectStageView(coordinator: self.coordinator),
                    isActive: $startUserJourney,
                    label: {
                        Button(action: {
                            Task {
                                // call API + getData
                                
                                let auditInfos = AuditInfos(
                                    buildingType: buildingType,
                                    name: name,
                                    buildingName: buildingName,
                                    address: address,
                                    email: email,
                                    phoneNumber: phoneNumber,
                                    notes: notes,
                                    date: Date.now
                                )
                                
                                
                                animateButton = true
                                // ask for steps lists
                                try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
                                
                                animateButton = false
                                // get steps list, and redirect to steps selection
                                startUserJourney = true
                            }
                        }){
                            if animateButton {
                                LoadingCircle()
                            } else {
                                Text("Page suivante")
                            }
                        }.buttonStyle(validateButtonStyle())
                    })
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

