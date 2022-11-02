//
//  CustomNavigation.swift
//  Onormes
//
//  Created by gonzalo on 01/04/2022.
//

import Foundation
import SwiftUI

enum UJPages {
    case stageSelection, regular;
}

class CustomNavCoordinator: ObservableObject { // regular can be the main page either summary or criteria page
    @Published var renderStepPage: UJPages = .regular;
    // others...
}

/**
 This class wrapp up the whole journey navigation page, it manages the buttons navigation display, as well as the button to add new stages/regulations.
 
**Constructor**
 ```swift
 init(content: @escaping () -> GenericRegulationView, navcoordinator: CustomNavCoordinator, coordinator: UJCoordinator, navigationButton: Bool)
 ```
 **Parameters**
 - content: closure to return the next view
 - navcoordinator: navigation coordinator
 - coordinator: user journey coordinator
 - navigationButton: variable indicating whether displaying the nav button or not
 */

struct UserJourneyNavigationPage: View {
    @State private var selectionTag: String?;
    
    let content: () -> GenericRegulationView;
    @ObservedObject var navcoordinator = CustomNavCoordinator();
    
    var coordinator: UJCoordinator;
    var navigationButton = false;
    
    init(content: @escaping () -> GenericRegulationView, coordinator: UJCoordinator, navigationButton: Bool) {
        self.content = content
        self.coordinator = coordinator
        self.navigationButton = navigationButton
    }
    
    var body: some View {
        VStack {
            if navcoordinator.renderStepPage == .stageSelection {
                GenericRegulationView(coordinator: coordinator, navcoordinator: navcoordinator)
            }
            else {
                HStack {
                    Spacer().frame(width: 290)
                    AddStageButton(action: {
                        print("before")
                        navcoordinator.renderStepPage = .stageSelection
                        print("after")
                    })
                }
                
                // own content
                Spacer()
                self.content().frame(maxWidth: .infinity, maxHeight: .infinity)
                if navigationButton {
                    VStack {
                        HStack {
                            if (self.coordinator.canGoBack()) {
                                CustomNavigationLink(coordinator: coordinator, tag: "goback", selection: $selectionTag,
                                    destination: {() -> GenericRegulationView in
                                    print("call go back")
                                    return self.coordinator.getPreviousView()}, navigationButton: !self.coordinator.done) {
                                    Button {
                                        self.coordinator.backToThePreviousStage()
                                        selectionTag = "goback"
                                    } label: {
                                        Image("LeftArrow")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 50)
                                    }
                                    .frame(width: 145, height: 38)
                                    .background(Color(hex: "29245A"))
                                    .cornerRadius(70)
                                    .transition(.slide)
                                }
                                
                                Spacer().frame(width: 10)
                                
                                CustomNavigationLink(coordinator: coordinator, tag: "skip", selection: $selectionTag, destination: {() -> GenericRegulationView in
                                    self.coordinator.getNextView()
                                    
                                }, navigationButton: !self.coordinator.done) {
                                    Button {
                                        if coordinator.stageDelegate!.formIsOkay() {
                                            // save data
                                            self.coordinator.stageDelegate!.modify(coordinator: self.coordinator)
                                            self.coordinator.nextStep()
                                            selectionTag = "skip"
                                        }
                                    } label: {
                                        Image("RightArrow")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50)
                                    }
                                    .frame(width: 145, height: 38)
                                    .background(Color(hex: "29245A"))
                                    .cornerRadius(70)
                                    .transition(AnyTransition.asymmetric(
                                        insertion: .move(edge: .trailing),
                                        removal: .move(edge: .leading)))
                                }
                                
                            } else {
                                CustomNavigationLink(coordinator: coordinator,
                                                     tag: "skip",
                                                     selection: $selectionTag,
                                                     destination: {() -> GenericRegulationView in
                                                                return self.coordinator.getNextView()},
                                                     navigationButton: !self.coordinator.done) {
                                    Button {
                                        if coordinator.stageDelegate!.formIsOkay() {
                                            // save data
                                            self.coordinator.stageDelegate!.modify(coordinator: self.coordinator)
                                            self.coordinator.nextStep()
                                            selectionTag = "skip"
                                        }
                                    } label: {
                                        Image("RightArrow")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 50)
                                    }
                                    .frame(width: 300, height: 38)
                                    .background(Color(hex: "29245A"))
                                    .cornerRadius(70)
                                    .transition(AnyTransition.asymmetric(
                                        insertion: .move(edge: .trailing),
                                        removal: .move(edge: .leading)))
                                }
                            }
                        }
                        
                        CustomNavigationLink(coordinator: coordinator,tag: "finished", selection: $selectionTag, destination: {() -> GenericRegulationView in
                            return self.coordinator.getNextView()}, navigationButton: false) {
                                Button("Finir l'audit") {
                                    // coordinator check
                                    coordinator.userJourneyFinished()
                                    selectionTag  = "finished"
                                }
                                .modifier(SecondaryButtonStyle1())
                                .transition(.slide)
                            }
                    }
                    Spacer().frame(height: 20)
            }
        }
    }

    }
}

/// This class manages RegulationsSelection page and the Substep page view
struct UserJourneyNavigationWrapper: View {
    let content: () -> GenericRegulationView;
    var coordinator: UJCoordinator;
    var navigationButton = false
    
    init(coordinator: UJCoordinator, content: @escaping () -> GenericRegulationView, navigationButton: Bool) {
        self.content = content
        self.coordinator = coordinator
        self.navigationButton = navigationButton
    }
    
    init(coordinator: UJCoordinator, @ViewBuilder content: @escaping () -> GenericRegulationView) {
        self.content = content
        self.coordinator = coordinator
    }
    
    var body: some View {
        VStack {
            // summary page
            if self.coordinator.hasFinished {
                //summaryPage
                SummaryWrapper(coordinator: self.coordinator,      content: self.content).navigationBarHidden(true)
            }
            // criterion page
            else {
                UserJourneyNavigationPage(content: content, coordinator: coordinator, navigationButton: self.navigationButton)
            }
        }
    }
}

/**
 This is class is a custom navigation link, it alter the native effect of the standard navigationLink.
 Thanks to that class we can retrieve and keep track of the data in the next steps. It allows us to have our own custom navigation bar with our own buttons
 
    **Constructors**:
 *Those constructor handle 3 different to build a navigation link:*
    - from **tag**  and **selection**: indicate on which tag the **NavigationLink** should be triggered
    - from **isActive**: if this variable turn to **True** the **NavigationLink** is triggered
 
```swift
 init(coordinator: UJCoordinator, destination: @escaping () -> GenericRegulationView, @ViewBuilder label: @escaping () -> Label)
```
 
```swift
 init(coordinator: UJCoordinator, tag: String, selection: Binding<String?>, destination: @escaping () -> GenericRegulationView, navigationButton: Bool, @ViewBuilder label: @escaping () -> Label)
 ```
  
```swift
 init(coordinator: UJCoordinator, isActive: Binding<Bool>, destination: @escaping () -> GenericRegulationView, @ViewBuilder label: @escaping () -> Label)
```

 
 
 */

struct CustomNavigationLink<Label: View> : View {
    let destination: () -> GenericRegulationView;
    let label: () -> Label;
    let constructorNumber: Int;
    let tag: String?;
    let selection: Binding<String?>?;
    var isActive: Binding<Bool>?;
    var coordinator: UJCoordinator;
    var navigationButton = true;
    
    init(coordinator: UJCoordinator, destination: @escaping () -> GenericRegulationView, @ViewBuilder label: @escaping () -> Label) {
        constructorNumber = 0
        self.destination = destination
        self.label = label
        self.coordinator = coordinator
        
        self.selection = nil
        self.tag = nil
        self.isActive = nil
    }
    init(coordinator: UJCoordinator, tag: String, selection: Binding<String?>, destination: @escaping () -> GenericRegulationView, navigationButton: Bool, @ViewBuilder label: @escaping () -> Label) {
        self.constructorNumber = 1
        self.selection = selection
        
        self.navigationButton = navigationButton
        
        self.tag = tag
        self.destination = destination
        self.label = label
        self.coordinator = coordinator
        self.isActive = nil
    }

    init(coordinator: UJCoordinator, isActive: Binding<Bool>, destination: @escaping () -> GenericRegulationView, @ViewBuilder label: @escaping () -> Label) {

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

/**
 This is class helps us to quite the current user journey and going back at the home menu, it remove also the native navigation top bar.
 
 **Parameters**
    - isActive: needed variable to trigger the **NavigationLink**
    - label: Button component of the **NavigationLink**
 */

struct QuitingNavigationLink<Label: View> : View {
    let label: () -> Label;
    let constructorNumber: Int;
    let tag: String?;
    var isActive: Binding<Bool>;
    
    init(isActive: Binding<Bool>, @ViewBuilder label: @escaping () -> Label) {
        constructorNumber = 0
        self.label = label
        
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

struct ReturnButtonWrapper<WrappedView: View>: View
{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let destination: () -> WrappedView;
    let action: (() -> Void)?;
    
    init(@ViewBuilder destination: @escaping () -> WrappedView) {
        self.destination = destination
        self.action = nil
    }
    
    init(action: @escaping () -> Void, @ViewBuilder destination: @escaping () -> WrappedView) {
        self.destination = destination
        self.action = action
    }

    
    var body: some View {
        VStack {
            HStack {
                Button("Retour") {
                    if action != nil {
                        action!()
                    }
                    presentationMode.wrappedValue.dismiss()
                }.modifier(SecondaryButtonStyle1(size: 100))

                Spacer().frame(width: 250)
            }
            Spacer()
                   .frame(height: 5)
            destination()
        }
    }
}

struct ReturnButton_Previews: PreviewProvider {
    static var previews: some View {
        ReturnButtonWrapper {
            CreateAuditView()
        }
    }
}
