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

struct UserJourneyNavigationPage<Content> : View where Content : PRegulationCheckView {
    @State private var selectionTag: String?;
    
    let content: Content;
    private unowned let navcoordinator: CustomNavCoordinator;
    var coordinator: UJCoordinator;
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>;
    
    init(content: Content, navcoordinator: CustomNavCoordinator, coordinator: UJCoordinator) {
        self.content = content
        self.coordinator = coordinator
        self.navcoordinator = navcoordinator
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
            Spacer()
            VStack {
                Text("And here the navigation controls")
                HStack {
//                    CustomNavigationLink(coordinator: self.coordinator,tag: "back", selection: $selectionTag, destination: UserJourney(coordinator: coordinator)) {
//                        Button("Retour") {
//                            // coordinator check
//                            selectionTag  = "back"
//                        }.buttonStyle(ButtonStyle())
//                    }
                    Button("Retour") {
                        // coordinator check
                        //selectionTag  = "back"
                        presentationMode.wrappedValue.dismiss()
                    }.buttonStyle(ButtonStyle())
                    
                    CustomNavigationLink(coordinator: coordinator,tag: "finished", selection: $selectionTag, destination: UserJourney(coordinator: coordinator)) {
                        Button("Finir l'audit") {
                            // coordinator check
                            selectionTag  = "finished"
                        }.buttonStyle(ButtonStyle())
                    }
                    CustomNavigationLink(coordinator: coordinator, tag: "skip", selection: $selectionTag, destination: UserJourney(coordinator: coordinator)) {
                        Button("Etape suivante") {
                            // coordinator check
                            // call coordinator to load the next page
                            if content.check() {
                                content.modify()
                                //TODO: handle redirection with coordinator
                            }
                            selectionTag  = "skip"
                        }.buttonStyle(ButtonStyle())
                    }
                }
            }
        }
    }

    
}

struct UserJourneyNavigationWrapper<Content> : View where Content : PRegulationCheckView {
    let content: Content;
    //@State private var selectionTag: String?;
    //@State private var renderStepPage: Bool = false;
    @ObservedObject var navcoordinator = CustomNavCoordinator();
    var coordinator: UJCoordinator;
    
    init(coordinator: UJCoordinator, content: Content) {
        self.content = content
        self.coordinator = coordinator
    }
    
    init(coordinator: UJCoordinator, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            if navcoordinator.renderStepPage {
                AccessibilityRegulationsPage(coordinator: coordinator, navcoordinator: navcoordinator)
            }
            else {
                UserJourneyNavigationPage(content: content,navcoordinator: navcoordinator, coordinator: coordinator)
            }
        }.navigationBarHidden(true)
    }
}

struct CustomNavigationLink<Label, Destination> : View where Label : View, Destination : PRegulationCheckView {
    let destination: Destination;
    let label: () -> Label;
    let constructorNumber: Int;
    let tag: String?;
    let selection: Binding<String?>?;
    var isActive: Binding<Bool>?;
    var coordinator: UJCoordinator;
    
    init(coordinator: UJCoordinator, destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        constructorNumber = 0
        self.destination = destination
        self.label = label
        self.coordinator = coordinator
        
        self.selection = nil
        self.tag = nil
        self.isActive = nil
    }
    init(coordinator: UJCoordinator, tag: String, selection: Binding<String?>, destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.constructorNumber = 1
        self.selection = selection
        self.tag = tag
        self.destination = destination
        self.label = label
        self.coordinator = coordinator
        
        self.isActive = nil
    }

    init(coordinator: UJCoordinator, isActive: Binding<Bool>, destination: Destination, @ViewBuilder label: @escaping () -> Label) {
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
                    UserJourneyNavigationWrapper(coordinator: coordinator, content: self.destination),
                label: label).navigationBarHidden(true)
        }
        if constructorNumber == 1 {
            NavigationLink(
                destination:
                UserJourneyNavigationWrapper(coordinator: coordinator, content: self.destination),
                tag: self.tag!,
                selection: self.selection!,
                label: label).navigationBarHidden(true)
        }
        if constructorNumber == 2 {
            NavigationLink(
                destination:
                UserJourneyNavigationWrapper(coordinator: coordinator,content: self.destination),
                isActive: self.isActive!,
                label: label).navigationBarHidden(true)
        }
    }
}
