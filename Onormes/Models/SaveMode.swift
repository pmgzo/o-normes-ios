//
//  SaveMode.swift
//  Onormes
//
//  Created by gonzalo on 17/09/2022.
//

import Foundation
import SwiftUI

func convertDataNormToDictionary(dataNorm: DataNorm) -> [String:Any] {
    var dic: [String:Any] = [:]
    let substepId = dataNorm.subStepId

    //for criterion in dataNorm.data {
    let criterion = dataNorm.data[0]
    
    if criterion.type == TypeField.bool {
        dic = [
            "id": criterion.id,
            "value": criterion.valueCheckBox,
            "comment": criterion.comment,
            "substepId": substepId
        ]
    }
    else  {
        dic = [
            "id": criterion.id,
            "value": criterion.valueMetric,
            "comment": criterion.comment,
            "substepId": substepId
        ]
    }
    //}
    return dic
}

func dataNormToDictionary(dataNormList: [DataNorm]) -> [[String:Any]] {
    var criteriaList: [[String:Any]] = []

    for criterion in dataNormList {
        // one data Norm has only one RegulationNorm
        criteriaList.append(convertDataNormToDictionary(dataNorm: criterion))
    }
    return criteriaList
}

// returns Dictionary which as an array of dictionaries
func convertStepIntoJson(data: [String:[DataNorm]]) -> [String:[[String:Any]]] {
    var newObject: [String:[[String:Any]]] = [:]
    for (id,value) in data {
        newObject[id] = dataNormToDictionary(dataNormList: value)
    }
    return newObject
}

func convertJsonToDataNorm(json: [String:Any]) -> DataNorm
{
    let subStep = json["subStep"] as! String
    
    let view = getSubSteps(id: subStep)
    
    let dataNormId = json["id"] as! String
    let reg = view.content![0]
    
    if reg.type == TypeField.bool {
        let regNorm = RegulationNorm(key: reg.key, inst: "", type: reg.type, valueBool: json["value"] as! Bool)
        
        return DataNorm(key: dataNormId, data: [regNorm], subStepId: subStep)
    } else {
        let regNorm = RegulationNorm(key: reg.key, inst: "", type: reg.type, valueString: json["value"] as! String)
        
        return DataNorm(key: dataNormId, data: [regNorm], subStepId: subStep)
    }
}

func convertJsonToStep(path: String) -> [String:[DataNorm]] {
    let string = try! String(contentsOfFile: path)
    
    let data = string.data(using: .utf8)!
    do {
        if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:[[String:Any]]]
        {
            var arr: [String:[DataNorm]] = [:]
            print(jsonArray)
            for (key, criteria) in jsonArray {
                //arr[key].append()
                var tmpArray: [DataNorm] = []
                for criterion in criteria {
                    tmpArray.append(convertJsonToDataNorm(json: criterion))
                }
                arr[key] = tmpArray
            }
            print("json as been loaded successfully")
            return arr
            
        } else {
            print("bad json")
        }
        
    } catch {
        print(error)
    }
    print("empty dic")
    return [:]
    
}

