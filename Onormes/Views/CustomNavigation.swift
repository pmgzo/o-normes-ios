//
//  CustomNavigation.swift
//  Onormes
//
//  Created by gonzalo on 01/04/2022.
//

import Foundation
import SwiftUI


class CustomNavCoordinator: ObservableObject {
    @Published var renderStepPage: Bool = false;
    // others...
}

struct UserJourneyNavigationPage: View {
    @State private var selectionTag: String?;
    
    let content: GenericRegulationView;
    private unowned let navcoordinator: CustomNavCoordinator;
    var coordinator: UJCoordinator;
    var navigationButton = false;
    
    init(content: GenericRegulationView, navcoordinator: CustomNavCoordinator, coordinator: UJCoordinator, navigationButton: Bool) {
        self.content = content
        self.coordinator = coordinator
        self.navcoordinator = navcoordinator
        self.navigationButton = navigationButton
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width: 290)
                Button(action: {
                    navcoordinator.renderStepPage = true
                }) {
                    Image(systemName: "plus").resizable().foregroundColor(.white).frame(width: 15, height: 15).padding()
                }.background(Color(hue: 246/360, saturation: 0.44, brightness: 0.24, opacity: 1)).cornerRadius(13).frame(width: 16, height: 16).padding()
            }
            
            // own content
            Spacer()
            self.content.frame(maxWidth: .infinity, maxHeight: .infinity)
            if navigationButton {
                Spacer()
                VStack {
                    HStack {
                        if (self.coordinator.canGoBack()) {
                            CustomNavigationLink(coordinator: coordinator,tag: "goback", selection: $selectionTag, destination: self.coordinator.getPreviousView(), navigationButton: false) {
                                Button("Retour") {
                                    self.coordinator.backToThePreviousStage()
                                    selectionTag = "goback"
                                }.buttonStyle(ButtonStyle())
                            }
                        }
                                                
                        // TODO: Add Recap page ?
                        CustomNavigationLink(coordinator: coordinator,tag: "finished", selection: $selectionTag, destination: self.coordinator.getNextView(forceQuit: true), navigationButton: false) {
                            Button("Finir l'audit") {
                                // coordinator check
                                selectionTag  = "finished"
                            }.buttonStyle(ButtonStyle())
                        }
                        
                        CustomNavigationLink(coordinator: coordinator, tag: "skip", selection: $selectionTag, destination: self.coordinator.getNextView(), navigationButton: !self.coordinator.done) {
                            Button("Etape suivante") {
                                if coordinator.stageDelegate!.formIsOkay() {
                                    print("step approved, modify data object")
                                    // save data
                                    self.coordinator.stageDelegate!.modify(coordinator: self.coordinator)
                                    self.coordinator.nextStep()
                                    selectionTag  = "skip"
                                    //TODO: handle redirection with coordinator
                                }
                            }.buttonStyle(ButtonStyle())
                        }
                    }
                }
            }
        }
    }

    
}

struct UserJourneyNavigationWrapper: View {
    let content: GenericRegulationView;
    @ObservedObject var navcoordinator = CustomNavCoordinator();
    var coordinator: UJCoordinator;
    var navigationButton = false
    
    init(coordinator: UJCoordinator, content: GenericRegulationView, navigationButton: Bool) {
        self.content = content
        self.coordinator = coordinator
        self.navigationButton = navigationButton
    }
    
    init(coordinator: UJCoordinator, @ViewBuilder content: () -> GenericRegulationView) {
        self.content = content()
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            if navcoordinator.renderStepPage {
                GenericRegulationView(coordinator: coordinator, navcoordinator: navcoordinator)
            }
            else {
                UserJourneyNavigationPage(content: content,navcoordinator: navcoordinator, coordinator: coordinator, navigationButton: self.navigationButton)
            }
        }.navigationBarHidden(true)
    }
}

struct CustomNavigationLink<Label: View> : View {
    let destination: GenericRegulationView;
    let label: () -> Label;
    let constructorNumber: Int;
    let tag: String?;
    let selection: Binding<String?>?;
    var isActive: Binding<Bool>?;
    var coordinator: UJCoordinator;
    var navigationButton = true;
    
    init(coordinator: UJCoordinator, destination: GenericRegulationView, @ViewBuilder label: @escaping () -> Label) {
        constructorNumber = 0
        self.destination = destination
        self.label = label
        self.coordinator = coordinator
        
        self.selection = nil
        self.tag = nil
        self.isActive = nil
    }
    init(coordinator: UJCoordinator, tag: String, selection: Binding<String?>, destination: GenericRegulationView, navigationButton: Bool, @ViewBuilder label: @escaping () -> Label) {
        self.constructorNumber = 1
        self.selection = selection
        
        self.navigationButton = navigationButton
        
        self.tag = tag
        self.destination = destination
        self.label = label
        self.coordinator = coordinator
        self.isActive = nil
    }

    init(coordinator: UJCoordinator, isActive: Binding<Bool>, destination: GenericRegulationView, @ViewBuilder label: @escaping () -> Label) {
        self.constructorNumber = 2
        self.isActive = isActive
        self.destination = destination
        self.label = label
        self.coordinator = coordinator
        
        self.selection = nil
        self.tag = nil
    }
    
    public var body: some View {
        if constructorNumber == 0 {
            NavigationLink(
                destination:
                    UserJourneyNavigationWrapper(coordinator: coordinator, content: self.destination, navigationButton: self.navigationButton),
                label: label).navigationBarHidden(true)
        }
        if constructorNumber == 1 {
            NavigationLink(
                destination:
                UserJourneyNavigationWrapper(coordinator: coordinator, content: self.destination, navigationButton: self.navigationButton),
                tag: self.tag!,
                selection: self.selection!,
                label: label).navigationBarHidden(true)
        }
        if constructorNumber == 2 {
            NavigationLink(
                destination:
                UserJourneyNavigationWrapper(coordinator: coordinator,content: self.destination, navigationButton: self.navigationButton),
                isActive: self.isActive!,
                label: label).navigationBarHidden(true)
        }
    }
}

struct QuitingNavigationLink<Label: View> : View {
    let label: () -> Label;
    let constructorNumber: Int;
    let tag: String?;
    let selection: Binding<String?>?;
    var isActive: Binding<Bool>;
    
    init(isActive: Binding<Bool>, @ViewBuilder label: @escaping () -> Label) {
        constructorNumber = 0
        self.label = label
        
        self.selection = nil
        self.tag = nil
        self.isActive = isActive
    }
    
    public var body: some View {
        // back to home menu
        NavigationLink(
            destination: HomeMenu().navigationBarHidden(true),
            isActive: self.isActive,
            label: label)
    }
}
