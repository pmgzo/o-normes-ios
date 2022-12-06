//
//  SaveMode.swift
//  Onormes
//
//  Created by gonzalo on 17/09/2022.
//

import Foundation
import SwiftUI

/**
 
 This function removes spaces
 
 */


func formatPath(pathFile: String) -> String {
    var str = ""
    for char in pathFile {
        if char == " " {
            str += String("%20")
        } else {
            str += String(char)
        }
    }
    return str
}

enum SavedModeErrorType: Error {
    case jsonError(reason: String)
}

// load

func deserializeRegulationNorms(criterion: [String:Any]) -> [RegulationNorm] {
    let value: String = criterion["value"] as! String
    let type: TypeField = value == "true" || value == "false" ? TypeField.bool : TypeField.string
    let comment: String = criterion["comment"] as! String
    let text: String = criterion["text"] as! String
    let name: String = criterion["name"] as! String

    let norm: RegulationNorm;
    
    if type == TypeField.bool {
        norm = RegulationNorm(key: name, inst: text, type: TypeField.bool, valueBool: value == "true" ? true : false)
    } else {
        norm = RegulationNorm(key: name, inst: text, type: TypeField.string, valueString: value)
    }
    
    return [
        norm,
        RegulationNorm(key: name + "-comment", inst: text, type: type,  mandatory: true, valueString: comment)
    ]
}

func deserializeCriterion(criterion: [String:Any]) -> DataNorm {
    
    let text: String = criterion["text"] as! String
    let name: String = criterion["name"] as! String
    
    if criterion["idSubCriterion"] != nil {
        var dataNorm = DataNorm(
            key: name,
            data: deserializeRegulationNorms(criterion: criterion),
            subStepId: text,
            idSubCriterion: criterion["idSubCriterion"] as? Int
        )
        dataNorm.photoList = criterion["photoList"] as! [String]
        return dataNorm
    }
    var dataNorm = DataNorm(
        key: name,
        data: deserializeRegulationNorms(criterion: criterion),
        subStepId: text)
    dataNorm.photoList = criterion["photoList"] as! [String]
    return dataNorm
}

func deserializeCriteria(criteria: [[String:Any]]) -> [DataNorm] {
    var criteriaList: [DataNorm] = []
    for criterion in criteria {
        criteriaList.append(
            deserializeCriterion(criterion: criterion)
        )
    }
    return criteriaList
}

func deserializeStage(stage: [String:Any]) -> StageWrite {
    return StageWrite(
        stageName: stage["stageName"] as! String,
        description: stage["description"] as! String,
        data: deserializeCriteria(criteria: stage["criteria"] as! [[String:Any]]),
        idBuilding: stage["idBuilding"] as! Int,
        idArea: stage["idArea"] as! Int,
        idPlace: stage["idPlace"] as! Int,
        idCriterion: stage["idCriterion"] as! Int
    )
}

func deserializeStages(stages: [[String:Any]]) -> [StageWrite] {
    
    var stageList: [StageWrite] = []

    for stage in stages {
        stageList.append(deserializeStage(stage: stage))
    }
    print(stageList)
    return stageList
}

func deserializeAuditInfos(auditInfos: [String:Any]) -> AuditInfos {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    return AuditInfos(
        buildingType: auditInfos["buildingType"] as! String,
        name: auditInfos["name"] as! String,
        buildingName: auditInfos["buildingName"] as! String,
        address: auditInfos["address"] as! String,
        siret: auditInfos["siret"] as! String,
        email: auditInfos["email"] as! String,
        phoneNumber: auditInfos["phoneNumber"] as! String,
        notes: auditInfos["notes"] as! String,
        date: dateFormatter.date(from: auditInfos["date"] as! String)!
    )
}

func readAuditFile(path: String) throws -> (AuditInfos, [StageWrite]) {
    
    let fileUrl = URL(string: "file://" + formatPath(pathFile: path))
    let jsonString = try String(contentsOf: fileUrl!)
    let data = jsonString.data(using: .utf8)!
    
    let jsonObject = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:Any]

    // get audti Infos
    let auditInfos = deserializeAuditInfos(auditInfos: jsonObject!["audit"] as! [String:Any])
        
    // get stageWrite
    let stages = deserializeStages(stages: jsonObject!["data"] as! [[String:Any]])

    return (auditInfos, stages)
}

// serialize

func serializeSubcriterion(criterion: DataNorm) -> [String:Any] {
    
    if criterion.idSubCriterion == nil {
        return [
            "value": getValueFromRegulationNormArray(regNorms: criterion.data),
            "comment": getCommentFromRegulationNormArray(regNorms: criterion.data),
            "text": criterion.subStepId,
            "name": criterion.key,
            "photoList": criterion.photoList
        ]
    }
    
    return [
        "idSubCriterion": criterion.idSubCriterion,
        "value": getValueFromRegulationNormArray(regNorms: criterion.data),
        "comment": getCommentFromRegulationNormArray(regNorms: criterion.data),
        "text": criterion.subStepId,
        "name": criterion.key,
        "photoList": criterion.photoList
    ]
}

func serializeCriteria(criteria: [DataNorm]) -> [[String:Any]]
{
    var array: [[String:Any]] = []
    for subcriterion in criteria {
        array.append(serializeSubcriterion(criterion: subcriterion))
    }
    return array
}

func serializeStage(stage: StageWrite) -> [String:Any] {
    return [
        "stageName": stage.stageName,
        "description": stage.description,
        "criteria": serializeCriteria(criteria: stage.data),
        "idBuilding": stage.idBuilding,
        "idArea": stage.idArea,
        "idPlace": stage.idPlace,
        "idCriterion": stage.idCriterion
    ]
}

func serializeStages(stages: [StageWrite]) -> [[String:Any]] {
    var array: [[String:Any]] = []
    for stage in stages {
        array.append(serializeStage(stage: stage))
    }
    return array
}

func serializeAuditInfos(auditInfos: AuditInfos) -> [String:Any]
{
    
//https://stackoverflow.com/questions/36861732/convert-string-to-date-in-swift
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    return [
        "buildingType": auditInfos.buildingType,
        "name": auditInfos.name,
        "buildingName": auditInfos.buildingName,
        "address": auditInfos.address,
        "siret": auditInfos.siret,
        "email": auditInfos.email,
        "phoneNumber": auditInfos.phoneNumber,
        "notes": auditInfos.notes,
        "date": dateFormatter.string(from: auditInfos.date)
    ]
}


func saveIntoJson(auditInfos: AuditInfos, savedData: [StageWrite]) {
    var savedObject: [String:Any] = [:]

    savedObject["audit"] = serializeAuditInfos(auditInfos: auditInfos)
    savedObject["data"] = serializeStages(stages: savedData)

    // save in json
    do {
        let userDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let pathToSavedAudit = userDirectory!.path + "/savedAudit"
        
        if FileManager.default.fileExists(atPath: pathToSavedAudit) == false {
            try FileManager.default.createDirectory(atPath: pathToSavedAudit, withIntermediateDirectories: true, attributes: nil)
        }
        
        let pathTowardFile = pathToSavedAudit + "/" + auditInfos.name + ".json"
        
        if FileManager.default.fileExists(atPath: pathTowardFile) == true {
            // erase existing file with the same name
            try FileManager.default.removeItem(atPath: pathTowardFile)
        }
        
        if !JSONSerialization.isValidJSONObject(savedObject) {
            throw SavedModeErrorType.jsonError(reason: "is not a valid json object")
        }
        
        let data = try JSONSerialization.data(withJSONObject: savedObject, options: .prettyPrinted)
        
        let success = FileManager.default.createFile(atPath: pathTowardFile, contents: data)
        
        if success {
            print("file \(auditInfos.name).json created")
        } else {
            print("fail to create the file \(auditInfos.name).json")
        }
    } catch {
        print(error)
    }
}
