//
//  OfflineMode.swift
//  Onormes
//
//  Created by gonzalo on 28/11/2022.
//

import Foundation
import SwiftUI

func serializeSubCriteria(subCriteria: [RegulationCheckField]) -> [[String:Any]] {
    var subCriteriaList: [[String:Any]] = []
    
    for subCriterion in subCriteria {
        if subCriterion.idSubCriterion != nil {
            subCriteriaList.append([
                "name": subCriterion.text,
                "idSubCriterion": subCriterion.idSubCriterion
            ])
        } else {
            subCriteriaList.append([
                "name": subCriterion.text,
            ])
        }
    }
    return subCriteriaList
}

func serializeStage(stage :StageRead) -> [String:Any] {
    
    var stageObject: [String:Any] = [:]

    stageObject["subCriteria"] = serializeSubCriteria(subCriteria: stage.content)
    stageObject["name"] = stage.name
    stageObject["idBuilding"] = stage.idBuilding
    stageObject["idArea"] = stage.idBuilding
    stageObject["idPlace"] = stage.idBuilding
    stageObject["idCriterion"] = stage.idCriterion
    return stageObject
}

func saveCriteria(criteriaObject: [[StageRead]]) throws {
    var dic: [[[String:Any]]] = []
    
    for stageList in criteriaObject {
        var dicStageList: [[String:Any]] = []
        for stage in stageList {
            dicStageList.append(serializeStage(stage: stage))
        }
        dic.append(dicStageList)
    }
    
    // write into directory
    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let directorySavedCriteria = userDirectory!.path + "/allCriteria"

    if FileManager.default.fileExists(atPath: directorySavedCriteria) == false {
        try FileManager.default.createDirectory(atPath: directorySavedCriteria, withIntermediateDirectories: true, attributes: nil)
    }
    
    let filePath = directorySavedCriteria + "/criteria.json"
    
    if !JSONSerialization.isValidJSONObject(dic) {
        throw FileErrorType.custom(reason: "La structure de donnée n'est pas un objet json valide")
    }
    
    let data = try JSONSerialization.data(withJSONObject: dic, options: .prettyPrinted)
    
    let success = FileManager.default.createFile(atPath: filePath, contents: data)
    
    if success {
        print("criteria list created")
    } else {
        print("fail to save criteria list created")
    }
}


func deserializeSubCriteria(serializedSubcriteria: [[String:Any]]) -> [RegulationCheckField] {
    var listRegCheck: [RegulationCheckField] = []

    for obj in serializedSubcriteria {
        if obj["idSubCriterion"] != nil {
            listRegCheck.append(
                RegulationCheckField(
                    key: obj["name"] as! String,
                    type: TypeField.bool,
                    text: obj["name"] as! String,
                    idSubCriterion: obj["idSubCriterion"] as! Int
                ))
        } else {
            listRegCheck.append(
                RegulationCheckField(
                    key: obj["name"] as! String,
                    type: TypeField.bool,
                    text: obj["name"] as! String
                ))
        }
    }
    return listRegCheck
}

func deserializeStage(serializedStage: [String:Any]) -> StageRead {
    let subCriteria = serializedStage["subCriteria"] as! [[String:Any]]
    
    return StageRead(
            name: serializedStage["name"] as! String,
            content: deserializeSubCriteria(serializedSubcriteria: subCriteria),
            idBuilding: serializedStage["idBuilding"] as! Int,
            idArea: serializedStage["idArea"] as! Int,
            idPlace: serializedStage["idPlace"] as! Int,
            idCriterion: serializedStage["idCriterion"] as! Int
        )
}

func deserializeStages(serializedStages: [[String:Any]]) -> [String:StageRead] {
    
    var stages: [String:StageRead] = [:]
    
    for stage in serializedStages {
        let deserializedStage = deserializeStage(serializedStage: stage)
        stages[deserializedStage.name] = deserializedStage
    }
    return stages
}

func readSaveCriteria(buildingTypeId: Int) throws -> [String:StageRead] {

    let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
    let pathToCriteria = userDirectory!.path + "/allCriteria/criteria.json"
    
    if FileManager.default.fileExists(atPath: pathToCriteria) == false {
        throw FileErrorType.custom(reason: "Le fichier n'existe pas")
    }
    
    let fileUrl = URL(string: "file://" + pathToCriteria)
    
    let jsonString = try String(contentsOf: fileUrl!)
    
    let data = jsonString.data(using: .utf8)!
    
    guard let jsonObject = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [[[String:Any]]] else {
        throw FileErrorType.custom(reason: "La structure écrite dans le fichier n'est pas un fichier json")
    }

    // convert id to its index
    let buildingStages = jsonObject[buildingTypeId - 1]

    let stages: [String:StageRead] = deserializeStages(serializedStages: buildingStages)
    return stages
}
