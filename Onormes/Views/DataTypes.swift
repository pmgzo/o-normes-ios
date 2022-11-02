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
    case description

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

/**
 
 Struct to save during the user journey

 */

class AuditInfos {
    var buildingType: String = "";
    var name: String = "";
    var buildingName: String = "";
    var address: String = "";
    var email: String = "";
    var phoneNumber: String = "";
    var notes: String = "";
    var date: Date = Date();
    
    init(
        buildingType: String,
        name: String,
        buildingName: String,
        address: String,
        email: String,
        phoneNumber: String,
        notes: String,
        date: Date
    ) {
        self.buildingType = buildingType
        self.name = name
        self.buildingName = buildingName
        self.address = address
        self.email = email
        self.phoneNumber = phoneNumber
        self.notes = notes
        self.date = date
    }
}

/**
 
 Audit Info struct to modify audit infos data
 
 */

class AuditInfosObject: ObservableObject {

    @Published var buildingType: String = "";
    @Published var name: String = "";
    @Published var buildingName: String = ""; // unused
    @Published var address: String = "";
    @Published var email: String = "";
    @Published var phoneNumber: String = "";
    @Published var notes: String = "";
    @Published var date: Date; // unused maybe only print it

    
    init(infos: AuditInfos) {
        self.buildingType = infos.buildingType
        self.name = infos.name
        self.buildingName = infos.buildingName
        self.address = infos.address
        self.email = infos.email
        self.phoneNumber = infos.phoneNumber
        self.notes = infos.notes
        self.date = infos.date
    }

    
    func hasChanged(refAudit: AuditInfos) -> Bool {
        if self.buildingType != refAudit.buildingType {
            return true
        }
        if self.name != refAudit.name {
            return true
        }
        if self.buildingName != refAudit.buildingName {
            return true
        }
        if self.address != refAudit.address {
            return true
        }
        if self.email != refAudit.email {
            return true
        }
        if self.phoneNumber != refAudit.phoneNumber {
            return true
        }
        if self.notes != refAudit.notes {
            return true
        }
        if self.date != refAudit.date {
            return true
        }
        return false
    }
}

/**
 
 Reading struct to render the displaying of a stage
 
 */

struct StageRead {
    let name: String;
    let content: [RegulationCheckField];
}

/**
 
 Writing struct to save data of a stage
 
 */

struct StageWrite {
    // maybe an id as reference once sending the infos
    let stageName: String;
    var description: String
    var data: [DataNorm];
}

extension StageWrite: Identifiable {
    var id: UUID {
        return UUID()
    }
}

