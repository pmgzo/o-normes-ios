//
//  SaveMode.swift
//  Onormes
//
//  Created by gonzalo on 17/09/2022.
//

import Foundation
import SwiftUI


// serialize


func convertDataNormToDictionary(dataNorm: DataNorm) -> [[String:Any]] {
    var dic: [[String:Any]] = []
    let substepId = dataNorm.subStepId

    // browse regulationNorm
    for criterion in dataNorm.data {
        if criterion.type == TypeField.bool {
            dic.append([
                "id": dataNorm.id,
                "key": criterion.key,
                "value": criterion.valueCheckBox,
                //"comment": criterion.comment,
                "substepId": substepId
            ])
            
        }
        else  {
            dic.append([
                "id": dataNorm.id,
                "key": criterion.key,
                "value": criterion.valueString,
                //"comment": criterion.comment,
                "substepId": substepId
            ])
        }
    }

    return dic
}

func dataNormToDictionary(dataNormList: [DataNorm]) -> [String:[[String:Any]]] {
    var criteriaList: [String:[[String:Any]]] = [:]

    for criterion in dataNormList {
        // one data Norm has only one RegulationNorm
        criteriaList[criterion.id] = convertDataNormToDictionary(dataNorm: criterion)

        //convertDataNormToDictionary(dataNorm: criterion)
    }
    return criteriaList
}

// returns Dictionary which as an array of dictionaries
func convertStepIntoJson(data: [String:[DataNorm]]) -> [String:[String:[[String:Any]]]] {
    var newObject: [String:[String:[[String:Any]]]] = [:]
    
    for (id,value) in data {
        newObject[id] = dataNormToDictionary(dataNormList: value)
    }
    print(newObject)
    return newObject
}

// load

func convertJsonToRegulationNorm(jsonArray: [[String:Any]]) -> DataNorm {
    var regNorms: [RegulationNorm] = []
    var id = ""
    var subStep = ""
    for obj in jsonArray {
        id = obj["id"] as! String
        subStep =  obj["substepId"] as! String
        let key = obj["key"] as! String
        let view = getSubSteps(id: subStep)
        let reg = view.content![0]

        if reg.type == TypeField.bool && !key.contains("-comment") {
            regNorms.append(RegulationNorm(key: key, inst: reg.text, type: reg.type, valueBool: obj["value"] as! Bool))
        } else if key.contains("-comment") {
            regNorms.append(RegulationNorm(key: key, inst: "", type: TypeField.string, valueString: obj["value"] as! String))
        } else {
            regNorms.append(RegulationNorm(key: key, inst: reg.text, type: reg.type, valueString: obj["value"] as! String))
        }
    }
    return DataNorm(key: id, data: regNorms, subStepId: subStep)
}

func convertJsonToDataNorm(json: [String:[[String:Any]]]) -> [DataNorm]
{
    var norms: [DataNorm] = []

    for (_,reglist) in json {
        norms.append(convertJsonToRegulationNorm(jsonArray: reglist))
    }
    return norms
}

func convertJsonToStep(path: String) -> [String:[DataNorm]] {
    let string = try! String(contentsOfFile: path)
    
    let data = string.data(using: .utf8)!
    do {
        if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String:[String:[[String:Any]]]]
        {
            var arr: [String:[DataNorm]] = [:]
            print(jsonArray)
            for (key, criteria) in jsonArray {
                arr[key] = convertJsonToDataNorm(json: criteria)
            }
            print("json has been loaded successfully")
            print(arr)
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

