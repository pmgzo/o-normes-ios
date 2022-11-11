//
//  CreateAudit.swift
//  Onormes
//
//  Created by gonzalo on 05/10/2022.
//

import Foundation
import SwiftUI


struct CreateViewForm: View {
    
    @State private var hasOpenBuildingType: Bool = false;
    
    var name: Binding<String>;
    var buildingName: Binding<String>;
    var buildingType: Binding<String>;
    var address: Binding<String>;
    var siret: Binding<String>;
    var email: Binding<String>;
    var phoneNumber: Binding<String>;
    var notes: Binding<String>;
    
    init(
        name: Binding<String>,
        buildingName: Binding<String>,
        buildingType: Binding<String>,
        address: Binding<String>,
        siret: Binding<String>,
        email: Binding<String>,
        phoneNumber: Binding<String>,
        notes: Binding<String>
    ) {
        self.buildingType = buildingType
        self.name = name
        self.buildingName = buildingName
        self.address = address
        self.siret = siret
        self.email = email
        self.phoneNumber = phoneNumber
        self.notes = notes
    }
    
    var body: some View {
        Text("Remplissez les données de l'audit").modifier(Header1(alignment: .center))
        
        Spacer().frame(height: 50)
        
        VStack {
            HStack {
                Text("Nom de l'audit")
                Spacer()
            }
            TextField("", text: name).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)

        VStack {
            HStack {
                Text("Nom de l'établissement")
                Spacer()
            }
            TextField("", text: buildingName).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)
        
        NavigationLink(
            destination: BuildingTypeSelection(buildingType: buildingType).navigationBarHidden(true),
            isActive: $hasOpenBuildingType,
            label: {
                Button(action: {
                    hasOpenBuildingType = true
                }) {
                    Text(buildingType.wrappedValue.isEmpty ? "Sélectionez un type d'établissement" : buildingType.wrappedValue).underline()
                }.buttonStyle(LinkStyle())
            }
        )
        
        VStack {
            HStack {
                Text("SIRET de l'entreprise")
                Spacer()
            }
            TextField("", text: siret).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)

        VStack {
            HStack {
                Text("Adresse de l'établissement")
                Spacer()
            }
            TextField("", text: address).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)
        
        VStack {
            HStack {
                Text("Numéro de téléphone du responsable")
                Spacer()
            }
            TextField("", text: phoneNumber).textFieldStyle(MeasureTextFieldStyle())
        }.frame(width:300)

        VStack {
            HStack {
                Text("Notes")
                Spacer()
            }
            TextField("", text: notes).textFieldStyle(CommentTextFieldStyle())
        }.frame(width:300)
    }
}

struct CreateAuditView: View {
    
    @ObservedObject var audit = AuditInfosObject(infos:                                                     AuditInfos(
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
    @State private var animateButton: Bool = false;
    @State private var startUserJourney: Bool = false;

    @State private var displayErrorMessage: Bool = false;
    @State var requestError: RequestError?;

    var coordinator = UJCoordinator()

    var body: some View {
        ReturnButtonWrapper {
            ScrollView(.vertical) {
                
                CreateViewForm(name: $audit.name,
                                      buildingName: $audit.buildingName,
                                      buildingType: $audit.buildingType,
                                      address: $audit.address,
                                      siret: $audit.siret,
                                      email: $audit.email,
                                      phoneNumber: $audit.phoneNumber,
                                      notes: $audit.notes
                        )

                Spacer()
                
                // submit button
                if !audit.buildingType.isEmpty && !audit.name.isEmpty && !audit.buildingName.isEmpty && !audit.siret.isEmpty {
                    NavigationLink(
                        destination: SelectStageView(coordinator: self.coordinator).navigationBarHidden(true),
                        isActive: $startUserJourney,
                        label: {
                            Button(action: {
                                Task {
                                    
                                    let auditInfos = audit.getData()
                                    
                                    self.coordinator.setAuditInfos(auditInfos: auditInfos)
                                    
                                    animateButton = true
                                    
                                    let buildingId = buildingTypeList.firstIndex(where: {$0 == audit.buildingType})! + 1
                                    
//                                    let stages = await APIService().getAllStages(buildingTypeId: buildingId)
                                    
                                    //TODO:
                                    // Retrieve data
                                    // convert it into StageRead type
                                    do {
                                        let stages = try await APIService().getAllStages(buildingTypeId: buildingId)
                                        self.coordinator.loadBuildingTypeStages(stages: stages)
                                        //                                    self.coordinator.loadBuildingTypeStages(stages: temporaryStageList)
                                    } catch ServerErrorType.internalError(let reason) {
                                        animateButton = false
                                        requestError = RequestError(errorDescription: reason)
                                        displayErrorMessage = true
                                        return
                                    } catch {
                                        animateButton = false
                                        requestError = RequestError(errorDescription: "Erreur interne")
                                        displayErrorMessage = true
                                        return
                                        //print(error)
                                    }
                                    
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
                    )
                    .modifier(PrimaryButtonStyle1())
                    .alert(
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
}

