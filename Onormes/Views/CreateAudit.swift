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
        ReturnButtonWrapper {
            ScrollView(.vertical) {
                Text("Remplissez les données de l'audit").modifier(Header1(alignment: .center))
                
                Spacer().frame(height: 50)
                
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
                    destination: BuildingTypeSelection(buildingType: $buildingType).navigationBarHidden(true),
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
                    NavigationLink(
                        destination: SelectStageView(coordinator: self.coordinator).navigationBarHidden(true),
                        isActive: $startUserJourney,
                        label: {
                            Button(action: {
                                Task {
                                    print("begging")
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
                                    
                                    //TODO:
                                    // Retrieve data
                                    // convert it into StageRead type
                                    print("here")
                                    
                                    self.coordinator.loadBuildingTypeStages(stages: temporaryStageList)
                                    
                                    animateButton = false
                                    // get steps list, and redirect to steps selection
                                    startUserJourney = true
                                }
                            })
                            {
                                if animateButton {
                                    LoadingCircle()
                                } else {
                                    Text("Page suivante")
                                }
                            }
                        }
                    ).modifier(PrimaryButtonStyle1())
                } else {
                    Button("Page suivante") {
                        // disabled button
                    }
                    .modifier(PrimaryDisabledButtonStyle1())
                }
                
            }
            Spacer().frame(height: 10)
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

