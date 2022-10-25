//
//  SavedAudit.swift
//  Onormes
//
//  Created by gonzalo on 13/09/2022.
//

import Foundation
import SwiftUI

struct PathSavedAudit: Identifiable {
    let name: String
    let id = UUID()
    init(path: String) {
        self.name = path
    }
}

struct SavedAudit: View {
    var savedAuditList: [PathSavedAudit]
    @State private var selectionTag: String?
    @ObservedObject var coordinator: UJCoordinator;

    init() {
        self.savedAuditList = []
        self.selectionTag = ""
        self.coordinator = UJCoordinator()
        
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let pathToSavedAudit = userDirectory!.path + "/savedAudit/"
        
        do {
            let allFiles = try FileManager.default.contentsOfDirectory(atPath: pathToSavedAudit)
            
            for file in allFiles {
                savedAuditList.append(PathSavedAudit(path: file))
            }
        } catch {
            print("fail to read files in the savedAudit directory")
        }
    }
    
    var body: some View {
        return NavigationView {
            List(self.savedAuditList) { audit in
                //Text(audit.name)
                CustomNavigationLink(coordinator: coordinator, tag: audit.name, selection: $selectionTag, destination: { () -> GenericRegulationView in
                    return self.coordinator.getNextView()},
                    navigationButton: false
                ,label: {
                    Button(audit.name) {
                        self.coordinator.userJourneyFinished()
                        
                        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
                        
                        let fullPath = userDirectory!.path + "/savedAudit/" + audit.name
                        
                        self.coordinator.loadPath(pathToLoad: fullPath)
                        self.coordinator.nextStep(start: true)
                        selectionTag = audit.name
                    }.buttonStyle(ButtonStyle())
                })
            }
        }
        
    }
}
