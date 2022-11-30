//
//  SavedAudit.swift
//  Onormes
//
//  Created by gonzalo on 13/09/2022.
//

import Foundation
import SwiftUI

class PathSavedAudit: Identifiable {
    let name: String
    let id = UUID()
    let date: String
    init(path: String, date: Date) {
        self.name = path[0...path.count - 6]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/YYYY à HH:mm"
        
        self.date = "Sauvegardé le " + formatter.string(from: date)
    }
}

func buildSavedAuditList() -> [PathSavedAudit] {
    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    
    let pathToSavedAudit = userDirectory!.path + "/savedAudit/"
    
    if FileManager.default.fileExists(atPath: pathToSavedAudit) == false {
        print("directory \(pathToSavedAudit) does not exist")
        return []
    }
    
    var savedAudit: [PathSavedAudit] = []
    
    do {
        let fileList = try FileManager.default.contentsOfDirectory(atPath: pathToSavedAudit)
        
         let tuples = fileList.map({ (elem) -> (String, Date) in
            //let attributes =
             let attributes = try! FileManager.default.attributesOfItem(atPath: pathToSavedAudit + elem)
             let creationDate = attributes[.creationDate] as! Date
            
            return (elem, creationDate)
         })
        
        let sortedTuple = tuples.sorted(by: {
            $0.1 > $1.1
        })
        
        for tuple in sortedTuple {
            savedAudit.append(PathSavedAudit(path: tuple.0, date: tuple.1))
        }
        
    } catch {
        print("failed to read file in \(pathToSavedAudit)")
        return []
    }
    return savedAudit
}

struct SavedAudit: View {
    @State var savedAuditList: [PathSavedAudit]
    //@State private var selectionTag: String?
    @ObservedObject var coordinator: UJCoordinator;
    @State private var selected = false;

    init() {
        print("init list")
        self.savedAuditList = buildSavedAuditList()
        //self.selectionTag = ""
        self.coordinator = UJCoordinator()
        self.coordinator.userJourneyFinished()
    }
    
    var body: some View {
        ReturnButtonWrapper {
            if savedAuditList.count == 0 {
                VStack {
                    Text("Pas d'audit(s) sauvegardé(s)")
                }.frame(maxHeight: .infinity, alignment: .center)
            }
            else {
                VStack {
                    Spacer().frame(height: 40)
                    
                    VStack {
                        CustomNavigationLink(
                            coordinator: coordinator,
                            isActive: $selected,
                            destination: { () -> GenericRegulationView in
                                return self.coordinator.getNextView()
                            }
                        ) {
                            EmptyView()
                        }
                    }.hidden()

                    Text("Liste des audits sauvegardés:").modifier(Header1())
                    Spacer().frame(height: 30)
                    List {
                    //List(self.savedAuditList) { audit in
                        ForEach(0...(self.savedAuditList.count - 1), id: \.self) { idx in
                                Button {
                                    print("clicked button")

                                    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first

                                    let fullPath = userDirectory!.path + "/savedAudit/" + self.savedAuditList[idx].name + ".json"
                                    
                                    print("load path")
                                    
                                    self.coordinator.loadPath(pathToLoad: fullPath)
                                    //self.coordinator.changeDelegate()
                                    
                                    print("after load path")

                                    selected = true
                                } label: {
                                    VStack {
                                        HStack {
                                            Text(self.savedAuditList[idx].name).modifier(Header3())
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                        Spacer()
                                        HStack {
                                            Text(self.savedAuditList[idx].date).italic().modifier(StageDescriptionText())
                                        }.frame(maxWidth: .infinity, alignment: .leading)
                                    }.frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }.onDelete(perform: removeRows)
                        }
                }
            }
        }.onAppear(perform: {
            self.savedAuditList = buildSavedAuditList()
        })
    }
    
    func removeRows(at offsets: IndexSet) {
        let indexes = Array(offsets)
        
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        let pathToSavedAudit = userDirectory!.path + "/savedAudit/"
        for idx in indexes {
            try! FileManager.default.removeItem(atPath: pathToSavedAudit +  self.savedAuditList[idx].name +  ".json")
            
            print("File \(self.savedAuditList[idx].name).json deleted")
            self.savedAuditList.remove(at: idx)
        }
    }
}
