//
//  DataType.swift
//  Onormes
//
//  Created by gonzalo on 11/07/2022.
//

import Foundation

//extension String {
//    var floatValue: Float {
//        return (self as NSString).floatValue
//    }
//}

enum PageType {
    case regular
    case addStage
    case summary
}

enum ViewModelUserJouneyError: Error {
    case missedInitializedVariable
    case stageNotInitialized
}

struct ERP_Config {
    //TODO: see what check needs to be added
    let hasMultipleFloor: Bool = true
    let hasElevator: Bool = true // maybe not usefull
}

enum TypeField {
    case string
    case float
    case bool
}

class IntegerRef {
    let value: String
    init(_ value: String) {
        self.value = value
    }
}

struct RegulationNorm: Identifiable {
    var id: String {get {return key}}
    
    let key: String;
    var valueMetric: String;
    var valueCheckBox: Bool;
    let instruction: String
    let mandatory: Bool;
    let type: TypeField;
    var comment: String;
    
    init(key: String, inst: String, type: TypeField, mandatory: Bool = true, valueString: String = "", valueBool: Bool = false) {
        self.key = key
        
        
        self.valueMetric = valueString
        self.valueCheckBox = valueBool
        self.comment = ""
        
        self.instruction = inst
        self.mandatory = mandatory
        self.type = type
    }
}

class DataNorm: Identifiable {
    var id: String {key}
    
    let key: String
    var data: [RegulationNorm]
    let subStepId: String
    
    init(key: String, data: [RegulationNorm], subStepId: String) {
        // data
        self.key = key
        self.data = data
        self.subStepId = subStepId
    }
}

class DataNormContainer: ObservableObject {
    @Published var data: [String:RegulationNorm] = [:]
    
    init(content: [RegulationCheckField]) {
        for (_, reg) in content.enumerated() {
            data[reg.key] = RegulationNorm(key: reg.key, inst: reg.text, type: reg.type, mandatory: reg.optional)
            let commentId = reg.key + "-comment";
            data[commentId] = RegulationNorm(key: commentId, inst: reg.text, type: TypeField.string, mandatory: reg.optional)
        }
    }
}

struct RegulationCheckField: Identifiable, Equatable {
    var id: ObjectIdentifier
    
    let key: String;
    let type: TypeField;
    let text: String;
    let optional: Bool;
    let comment: String;
    init(key: String, type: TypeField, text: String, optional: Bool = false) {
        self.key = key;
        self.type = type;
        self.text = text;
        self.optional = optional;
        self.comment = "";
        
        self.id = ObjectIdentifier(IntegerRef(UUID().uuidString))
    }
}
