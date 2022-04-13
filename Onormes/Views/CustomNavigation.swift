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

// Page to add Stages
struct AccessibilityRegulationsPage: PRegulationCheckView {
    //TODO: update navigation here
    @State private var selectionTag: String?;
//    private unowned let coordinator: CustomNavCoordinator;
//
    var navcoordinator: CustomNavCoordinator;
    var coordinator: UJCoordinator;
    
    init(coordinator: UJCoordinator, navcoordinator: CustomNavCoordinator) {
        self.navcoordinator = navcoordinator
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Retour") {
                    // coordinator check
                    self.navcoordinator.renderStepPage = false
                }.buttonStyle(ButtonStyle())
                Spacer().frame(width: 250)
            }
            Spacer()
            //TODO: DELETE ?
            Text("Here you will get the accessibility rules you can add to the audit")
            CustomNavigationLink(coordinator: coordinator, tag: "doorChecking", selection: $selectionTag, destination: AccessibilityRegulationsPage(coordinator: coordinator, navcoordinator: navcoordinator)) {
                Button("Add external door checking") {
                    selectionTag = "doorChecking"
                }
            }
            CustomNavigationLink(coordinator: coordinator, tag: "doorChecking2", selection: $selectionTag, destination: AccessibilityRegulationsPage(coordinator: coordinator, navcoordinator: navcoordinator)) {}
        }
    }
    
    func check() -> Bool {
        return true
    }
    
    func modify() -> Bool {
        return true
    }
}

struct UserJourneyNavigationPage<Content> : View where Content : PRegulationCheckView {
    @State private var selectionTag: String?;
    
    let content: Content;
    private unowned let navcoordinator: CustomNavCoordinator;
    var coordinator: UJCoordinator;
    
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
                    CustomNavigationLink(coordinator: self.coordinator,tag: "back", selection: $selectionTag, destination: UserJourney(coordinator: coordinator)) {
                        Button("Retour") {
                            // coordinator check
                            selectionTag  = "back"
                        }.buttonStyle(ButtonStyle())
                    }
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


struct AccessibilityRegulationsPage_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            AccessibilityRegulationsPage(coordinator: UJCoordinator(), navcoordinator: CustomNavCoordinator())
        }
      }
  }
