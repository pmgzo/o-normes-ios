//
//  CreateAudit.swift
//  Onormes
//
//  Created by gonzalo on 05/10/2022.
//

import Foundation
import SwiftUI


struct CreateViewForm: View {
    @ObservedObject var audit = AuditInfosObject(infos:                                         AuditInfos(
                                        buildingType: "",
                                        name: "",
                                        buildingName: "",
                                        address: "",
                                        siret: "",
                                        email: "",
                                        phoneNumber: "",
                                        notes: "",
                                        date: Date()
                                    ));
    
    @State private var hasOpenBuildingType: Bool = false;
    
    var body: some View {
        Text("Remplissez les données de l'audit").modifier(Header1(alignment: .center))
        
        Spacer().frame(height: 50)
        
        VStack {
            HStack {
                Text("Nom de l'audit")
                Spacer()
            }
            TextField("", text: $audit.name).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)

        VStack {
            HStack {
                Text("Nom de l'établissement")
                Spacer()
            }
            TextField("", text: $audit.buildingName).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)
        
        NavigationLink(
            destination: BuildingTypeSelection(buildingType: $audit.buildingType).navigationBarHidden(true),
            isActive: $hasOpenBuildingType,
            label: {
                Button(action: {
                    hasOpenBuildingType = true
                }) {
                    Text(audit.buildingType.isEmpty ? "Sélectionez un type d'établissement" : audit.buildingType).underline()
                }.buttonStyle(LinkStyle())
            }
        )
        
        VStack {
            HStack {
                Text("SIRET de l'entreprise")
                Spacer()
            }
            TextField("", text: $audit.siret).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)

        VStack {
            HStack {
                Text("Adresse de l'établissement")
                Spacer()
            }
            TextField("", text: $audit.address).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)
        
        VStack {
            HStack {
                Text("Numéro de téléphone du responsable")
                Spacer()
            }
            TextField("", text: $audit.phoneNumber).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)

        VStack {
            HStack {
                Text("Notes")
                Spacer()
            }
            TextField("", text: $audit.notes).textFieldStyle(CommentTextFieldStyle())
        }.frame(width:300)
    }
}

struct CreateAuditView: View {
    
    
    var form = CreateViewForm()
    
    @State private var animateButton: Bool = false;
    @State private var startUserJourney: Bool = false

    var coordinator = UJCoordinator()

    var body: some View {
        ReturnButtonWrapper {
            ScrollView(.vertical) {
                
                self.form

                Spacer()
                
                // submit button
                if self.validateTest() {
                    NavigationLink(
                        destination: SelectStageView(coordinator: self.coordinator).navigationBarHidden(true),
                        isActive: $startUserJourney,
                        label: {
                            Button(action: {
                                Task {
                                    // call API + getData
                                    
                                    let auditInfos = form.audit.getData()
                                    
                                    self.coordinator.setAuditInfos(auditInfos: auditInfos)
                                    
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
    
    func validateTest() -> Bool {
        let audit = form.audit.getData()
        if !audit.buildingType.isEmpty && !audit.name.isEmpty && !audit.buildingName.isEmpty && !audit.siret.isEmpty {
            return true
        }
        return false
    }
}

