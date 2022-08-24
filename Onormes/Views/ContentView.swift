  //
  //  ContentView.swift
  //  Onormes
  //
  //  Created by Toufik Belgacemi on 30/10/2021.
  //

  import SwiftUI

/**
 
 This class handles the bar navigation view, redirect the user according to what he has clicked
 
 */

  struct ContentView: View {
        var body: some View {
            VStack(alignment: .center, content: {
                TabView {
                  MeasuresVCRepresented()
                    .tabItem {
                      Image(systemName: "ruler.fill")
                      Text("Mesures")
                    }
                  
                  ReconstructionVCRepresented()
                    .tabItem {
                      Image(systemName: "sensor.tag.radiowaves.forward.fill")
                      Text("LiDAR")
                    }
                  
                    HomeMenu()
                    .tabItem {
                      Image(systemName: "house")
                      Text("Accueil")
                    }
                  
                  ProfileView()
                    .tabItem {
                      Image(systemName: "person.circle.fill")
                      Text("Profil")
                    }
                }.accentColor(Color(hex: 0x282359))
            }).preferredColorScheme(.light).navigationBarHidden(true)

        }
  }

struct ReconstructionVCRepresented : UIViewControllerRepresentable {
  func updateUIViewController(_ uiViewController: ReconstructionViewController, context: Context) {
      
  }
  
  func makeUIViewController(context: Context) -> ReconstructionViewController {
    UIStoryboard(name: "Reconstruction", bundle: Bundle.main).instantiateViewController(identifier: "ReconstructionViewController") as! ReconstructionViewController
  }
}

struct MeasuresVCRepresented : UIViewControllerRepresentable {
  func updateUIViewController(_ uiViewController: AreaViewController, context: Context) {
  }
  
  func makeUIViewController(context: Context) -> AreaViewController {
    UIStoryboard(name: "Measure", bundle: Bundle.main).instantiateViewController(identifier: "AreaViewController") as! AreaViewController
  }
}

/**
 This structure render the home page. From this page we can access to the user journey.
 
 This is here where the **UJCoordinator** is created, before starting the user journey.
 
 **Properties**:
 - coordinator: user journey handler
 - isShowingDetailView: variable used to trigger the user journey 's **NavigationLink** button
 
 */

struct HomeMenu: View {
    
    @State private var isShowingDetailView = false
    @ObservedObject var coordinator: UJCoordinator;
    
    init() {
        self.coordinator = UJCoordinator()
    }
    
    var body: some View {
        return NavigationView {
            VStack {
                Text("Vous êtes connecté !")
                CustomNavigationLink(coordinator: coordinator, isActive: $isShowingDetailView, destination: { () -> GenericRegulationView in
                    return self.coordinator.getNextView()
                },label: {
                    Button("Commencer le parcours utilisateur") {
                        self.coordinator.nextStep(start: true)
                        isShowingDetailView = true
                    }.buttonStyle(ButtonStyle())
                })
            }
        }
    }
};

struct HomeMenu_Previews: PreviewProvider {
  static var previews: some View {
    Group {
        HomeMenu()
    }
  }
}
