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

    init() {
        self.savedAuditList = []
        
        let userDirectory = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first
        
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
        List(self.savedAuditList) { audit in
            Text(audit.name)
        }
    }
}
