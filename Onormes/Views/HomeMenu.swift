//
//  HomeMenu.swift
//  Onormes
//
//  Created by Toufik Belgacemi on 30/10/2021.
//


import Foundation
import SwiftUI

struct LogoMenuImage: View {
  var body: some View {
    Image("Logo")
      .resizable()
      .aspectRatio(contentMode: .fit)
      .frame(width: 260)
  }
}

func getCurrentDay() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "d"
    let dayString = dateFormatter.string(from: date)
    return dayString
}

let frenchMonths = [
    "Janvier",
    "Février",
    "Mars",
    "Avril",
    "Mai",
    "Juin",
    "Juillet",
    "Août",
    "Septembre",
    "Octobre",
    "Novembre",
    "Décembre"
]

func getCurrentMonth() -> String {
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "M"
    let monthIndex = Int(dateFormatter.string(from: date))!
    return frenchMonths[monthIndex - 1]
}

func getCurrentYear() -> String{
    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY"
    let yearString = dateFormatter.string(from: date)
    return yearString
}





/**
This structure render the home page. From this page we can access to the user journey.

This is here where the **UJCoordinator** is created, before starting the user journey.

**Properties**:
- coordinator: user journey handler
- isShowingDetailView: variable used to trigger the user journey 's **NavigationLink** button

*/

struct HomeMenu: View {
  
    @State private var hasStartUserJouney = false
    @State private var hasOpenedTheFeedbackPage = false
    @State private var hasOpenedNotSentAudit = false

    @ObservedObject var coordinator: UJCoordinator;
    @EnvironmentObject var appState: AppState
    @StateObject private var userVM = UserViewModel()
    @State var animateButton = false
    @State var displayErrorMessage: Bool = false;
    @State var requestError: RequestError?;

    @State var fileExist: Bool
    @State var updateDate: String

    init() {
        self.coordinator = UJCoordinator()
        
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = userDirectory!.path + "/allCriteria/criteria.json"
        
        if FileManager.default.fileExists(atPath: filePath) == true {
            fileExist = true
            
            // get the date
            let attributes = try! FileManager.default.attributesOfItem(atPath: filePath)
            let creationDate = attributes[.creationDate] as! Date

            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/YYYY"
            
            self.updateDate = formatter.string(from: creationDate)
        } else {
            fileExist = false
            self.updateDate = ""
        }
    }
  
    var body: some View {
      return NavigationView {
          VStack {
              
              if appState.offlineModeActivated == false {
                  Text("Bonjour \(userVM.user?.first_name ?? "")")
                      .font(.system(size: 25))
                      .fontWeight(.semibold)
                      .foregroundColor(Color(hex: "29245A"))
                      .multilineTextAlignment(.center)
                      .onAppear(perform: {
                        userVM.getCurrentUser()
                      })
                  
                  Spacer().frame(height: 40)

                  Text("Nous sommes le \(getCurrentDay()) \(getCurrentMonth()) \(getCurrentYear())") .foregroundColor(Color(hex: "29245A"))
                      .multilineTextAlignment(.center)
                  Text("Passez une bonne journée") .foregroundColor(Color(hex: "29245A"))
                      .multilineTextAlignment(.center)
              } else {
                  Text("Mode offline")
                      .font(.system(size: 25))
                      .foregroundColor(Color(hex: "29245A"))
                      .multilineTextAlignment(.center)
              }
              
              LogoMenuImage()
              
              NavigationLink(
                  destination: CreateAuditView().navigationBarHidden(true),
                  isActive: $hasStartUserJouney,
                  label: {
                      Button("Réaliser un diagnostic") {
                          hasStartUserJouney = true
                      }.modifier(PrimaryButtonStyle1(size: 300))
                  }
              )
              
              NavigationLink(
                destination:  SavedAudit().navigationBarHidden(true),
                  isActive: $hasOpenedNotSentAudit,
                  label: {
                      Button("Audits sauvegardés") {
                          hasOpenedNotSentAudit = true
                      }.modifier(SecondaryButtonStyle1(size: 300))
                  }
              )
              
              NavigationLink(
                  destination: FeedbackView().navigationBarHidden(true),
                  isActive: $hasOpenedTheFeedbackPage,
                  label: {
                      Button("Donner un feedback") {
                          hasOpenedTheFeedbackPage = true
                      }.modifier(SecondaryButtonStyle1(size: 300))
                  }
              )
              
              if fileExist {
                  Text("Dernière mise à jour le \(updateDate)").modifier(ModeOfflineInformationText())
              } else {
                  Text("Pour pouvoir utiliser le mode offline\nVeuillez télécharger les critères")
                      .underline()
                      .modifier(ModeOfflineSuggestionText())
              }

              Button(action: {
                  Task {
                      animateButton = true
                      
                      // query all stages
                      do {
                          if fileExist {
                              // if already have the file nothing to do
                              try await Task.sleep(nanoseconds: UInt64(1 * Double(NSEC_PER_SEC)))
                              animateButton = false
                              return
                          }
                          
                          let criteriaObject = try await APIService().downloadAllCriteria()
                          
                          // save in file
                          try saveCriteria(criteriaObject: criteriaObject)
                          
                          // dynamic rendering update
                          checkCriteriaFile()
                          
                          animateButton = false
                      } catch ServerErrorType.internalError(let reason) {
                          animateButton = false
                          requestError = RequestError(errorDescription: reason)
                          displayErrorMessage = true
                          return
                      } catch {
                          animateButton = false
                          requestError = RequestError(errorDescription: "Internal Error")
                          displayErrorMessage = true
                          return
                      }
                  }
              }, label: {
                  HStack {
                      if animateButton {
                          LoadingCircle()
                      } else {
                          Text(!fileExist ? "Télécharger les critères" : "Mettre à jour les critères")
                      }
                  }.modifier(PrimaryButtonStyle1(size: 300))
              })
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
          }
          Spacer().frame(height: 100)
      }
    }

    func checkCriteriaFile() {
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let filePath = userDirectory!.path + "/allCriteria/criteria.json"
        
        if FileManager.default.fileExists(atPath: filePath) == true {
            self.fileExist = true
            
            // get the date
            let attributes = try! FileManager.default.attributesOfItem(atPath: filePath)
            let creationDate = attributes[.creationDate] as! Date

            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/YYYY"
            
            self.updateDate = formatter.string(from: creationDate)
        } else {
            self.fileExist = false
            self.updateDate = ""
        }
    }
    
    
};

struct HomeMenu_Previews: PreviewProvider {
    @StateObject var appState = AppState()
    
    static var previews: some View {
      Group {
          HomeMenu()
      }
    }
}
