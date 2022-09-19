//
//  DataTypes.swift
//  Onormes
//
//  Created by gonzalo on 11/07/2022.
//

import Foundation

/**
 This enum type is used in **UserJourneyNavigationWrapper**, to see the current state of the page, and acts accordingly to which button the user has clicked on.
 
 */

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

/**
 This enum type is used to see what kind of form is it render on the **GenericRegulationView**.
 - string: is usually a grand box of free text typing
 - float: is dedicated for measures
 - bool: represent a checkbox
 
 This type is import for the **DataNorm** type which is the user journey's saved data
 */

enum TypeField: Int {
    case string = 1
    case float
    case bool
    case category
}

class IntegerRef {
    let value: String
    init(_ value: String) {
        self.value = value
    }
}

/**
 This is the structure used as data which is filled during the user journey navigation.
 It is filled in the GenericRegulationViewModel once the user has clicked to the next button. The data is thereafter send to the UserJourneyCoordinator class.
 Could be either the regulation's comment or the regulation value
 
 - Properties:
    - id: regulation's identifier
    - key: same as **id**
    - valueString: written value by the user  (if the field is not a checkbox)
    - valueCheckBox: checkBox value (if the field is a checkbox)
    - mandatory:indicate whether the value must be fieled
    - type:type of the value (Bool, Text, Metric)
    - comment: comment in a addiction to the value
 
 */

struct RegulationNorm: Identifiable {
    var id: String {get {return key}}
    
    let key: String;
    var valueString: String;
    var valueCheckBox: Bool;
    let instruction: String // useless
    let mandatory: Bool;
    let type: TypeField;

    init(key: String, inst: String, type: TypeField, mandatory: Bool = true, valueString: String = "", valueBool: Bool = false) {
        self.key = key
        
        
        self.valueString = valueString
        self.valueCheckBox = valueBool
        
        self.instruction = inst
        self.mandatory = mandatory
        self.type = type
    }
}

func getCommentFromRegulationNormArray(regNorms: [RegulationNorm]) -> String {
    for norm in regNorms {
        if norm.key.contains("-comment'") {
            return norm.valueString
        }
    }
    return ""
}

func getRegulationFromRegulationNormArray(regNorms: [RegulationNorm]) -> RegulationNorm {
    for norm in regNorms {
        if !norm.key.contains("-comment'") {
            return norm
        }
    }
    return regNorms[0]
}

/**
 This is class is like a **RegulationNorm** container.
 This class is used to save data dynamicaly in the **UserJourneyCoordinator** class
 This class contain all the data of one stage.
 
 - Properties:
    - id: identifier
    - key: same as **id**
    - data: array of **RegulationNorm** (regulation checks in a stage)
 
 */

class DataNorm: Identifiable {
    var id: String {key}
    
    let key: String
    
    var data: [RegulationNorm]
    let subStepId: String
    
    init(key: String, data: [RegulationNorm], subStepId: String) {
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

/**
 This struct is used to define form within **GenericRegulationView** that is substep.
 
 - Properties:
    - id: key
    - key: same as id
    - type: type of the field
    - text: form's label, field's description
    - optional: if this form is optional
    - comment: comment
 
 */

struct RegulationCheckField: Identifiable, Equatable {
    var id: ObjectIdentifier
    
    let key: String;
    let type: TypeField;
    let text: String;
    let optional: Bool;
    let comment: String;
    let menusCategories: [String];
    
    init(key: String, type: TypeField, text: String, categories: [String] = [], optional: Bool = false) {
        self.key = key;
        self.type = type;
        self.text = text;
        self.optional = optional;
        self.menusCategories = categories;
        self.comment = "";
        
        self.id = ObjectIdentifier(IntegerRef(UUID().uuidString))
    }
}

