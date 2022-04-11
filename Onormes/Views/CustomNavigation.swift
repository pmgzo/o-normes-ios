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
    private unowned let coordinator: CustomNavCoordinator;
    
    init(coordinator: CustomNavCoordinator) {
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            HStack {
                Button("Retour") {
                    // coordinator check
                    self.coordinator.renderStepPage = false
                }.buttonStyle(ButtonStyle())
                Spacer().frame(width: 250)
            }
            Spacer()
            Text("Here you will get the accessibility rules you can add to the audit")
            CustomNavigationLink(tag: "doorChecking", selection: $selectionTag, destination: AccessibilityRegulationsPage(coordinator: coordinator)) {
                Button("Add external door checking") {
                    selectionTag = "doorChecking"
                }
            }
            CustomNavigationLink(tag: "doorChecking2", selection: $selectionTag, destination: AccessibilityRegulationsPage(coordinator: coordinator)) {}
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
    private unowned let coordinator: CustomNavCoordinator;
    
    init(content: Content, coordinator: CustomNavCoordinator) {
        self.content = content
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer().frame(width: 290)
                Button(action: {
                    coordinator.renderStepPage = true
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
                    CustomNavigationLink(tag: "back", selection: $selectionTag, destination: UserJourney()) {
                        Button("Retour") {
                            // coordinator check
                            selectionTag  = "back"
                        }.buttonStyle(ButtonStyle())
                    }
                    CustomNavigationLink(tag: "finished", selection: $selectionTag, destination: UserJourney()) {
                        Button("Finir l'audit") {
                            // coordinator check
                            selectionTag  = "finished"
                        }.buttonStyle(ButtonStyle())
                    }
                    CustomNavigationLink(tag: "skip", selection: $selectionTag, destination: UserJourney()) {
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
    @ObservedObject var coordinator = CustomNavCoordinator();
    
    init(content: Content) {
        self.content = content
    }
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            if coordinator.renderStepPage {
                AccessibilityRegulationsPage(coordinator: coordinator)
            }
            else {
                UserJourneyNavigationPage(content: content, coordinator: coordinator)
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
    
    init(destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        constructorNumber = 0
        self.destination = destination
        self.label = label
        
        self.selection = nil
        self.tag = nil
        self.isActive = nil
    }
    init(tag: String, selection: Binding<String?>, destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.constructorNumber = 1
        self.selection = selection
        self.tag = tag
        self.destination = destination
        self.label = label
        
        self.isActive = nil
    }

    init(isActive: Binding<Bool>, destination: Destination, @ViewBuilder label: @escaping () -> Label) {
        self.constructorNumber = 2
        self.isActive = isActive
        self.destination = destination
        self.label = label
        
        self.selection = nil
        self.tag = nil
    }
    
    public var body: some View {
        if constructorNumber == 0 {
            NavigationLink(
                destination:
                UserJourneyNavigationWrapper(content: self.destination),
                label: label).navigationBarHidden(true)
        }
        if constructorNumber == 1 {
            NavigationLink(
                destination:
                UserJourneyNavigationWrapper(content: self.destination),
                tag: self.tag!,
                selection: self.selection!,
                label: label).navigationBarHidden(true)
        }
        if constructorNumber == 2 {
            NavigationLink(
                destination:
                UserJourneyNavigationWrapper(content: self.destination),
                isActive: self.isActive!,
                label: label).navigationBarHidden(true)
        }
    }
}


struct AccessibilityRegulationsPage_Previews: PreviewProvider {
      static var previews: some View {
        Group {
            AccessibilityRegulationsPage(coordinator: CustomNavCoordinator())
        }
      }
  }
