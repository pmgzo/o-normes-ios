//
//  ReferencedSubSteps.swift
//  Onormes
//
//  Created by gonzalo on 11/07/2022.
//

import Foundation
import SwiftUI


let subStepsMap: [String:GenericRegulationView] =  [
    "alléestructurante-1": GenericRegulationView(title: "Page allée structurante", content: [RegulationCheckField(key: "alléestructurante", type: TypeField.string, text: "Saisissez la largeur du couloir, (le couloir doit avoir au minimum 1.20m de largeur)", optional: false)], id: "alléestructurante", subStepId: "alléestructurante-1"),
    "alléenonstructurante-1": GenericRegulationView(title: "Page allée non structurante", content: [RegulationCheckField(key: "alléenonstructurante", type: TypeField.string, text: "Saisissez la largeur du couloir, (le couloir doit avoir au minimum 1.05m de largeur au sol et 90cm à partir de 0.2m de hauteur)", optional: false)], id: "alléenonstructurante", subStepId: "alléenonstructurante-1"),
    "portedentrée-1": GenericRegulationView(title: "Porte d'entrée", content: [RegulationCheckField(key: "portedentrée", type: TypeField.string, text: "Saisissez la largeur de la porte d'entrée", optional: false)], id: "portedentrée", subStepId: "portedentrée-1"),
    "filedattente-1": GenericRegulationView(title: "File d'attente", content: [RegulationCheckField(key: "filedattente", type: TypeField.bool, text: "L'appuis ischiatique est à une hauteur d'environ 0.70m ", optional: true)], id: "filedattente", subStepId: "filedattente-1"),
    "escalier-1": GenericRegulationView(title: "Escalier",  content: [
        RegulationCheckField(key: "largeurmaincourante", type: TypeField.string, text: "Saisissez la largeur entre main courant (La largeur minimum à respecter est de 1m)", optional: false)], id: "escalier", subStepId: "escalier-1"),
    "escalier-2": GenericRegulationView(title: "Escalier", content: [RegulationCheckField(key: "gironmarche", type: TypeField.string, text: "Saisissez la mesure du giron (g) (cette mesure doit respecter la relation Blondel : 60 cm < 2 h + g < 64cm)", optional: false)], id: "escalier", subStepId: "escalier-2"),
    "escalier-3": GenericRegulationView(title: "Escalier", content: [RegulationCheckField(key: "hauteurmarch", type: TypeField.string, text: "Saisissez la hauteur (h) de marche (cette mesure doit respecter la relation Blondel : 60 cm < 2 h + g < 64cm)", optional: false)], id: "escalier", subStepId: "escalier-3"),
    "ascenseur-1": GenericRegulationView(title: "Ascenseur", content: [
        RegulationCheckField(key: "commandeascenseur", type: TypeField.string, text: "Les commandes intérieures doit avoir une hauteur du sol comprise entre 0.9m et 1.2m", optional: false)], id: "ascenseur", subStepId: "ascenseur-1"),
    "ascenseur-2": GenericRegulationView(title: "Ascenseur", content: [
        RegulationCheckField(key: "ascenseurmaincourante", type: TypeField.string, text: "La main courante doit être comprise entre 87.5cm et 92.5cm", optional: false)], id: "ascenseur", subStepId: "ascenseur-2"),
    "ascenseur-3": GenericRegulationView(title: "Ascenseur", content: [
        RegulationCheckField(key: "ascenseurcatune", type: TypeField.bool, text: "Ascenseur type 1: 1,25m x 1m avec un passage libre de 80cm", optional: false)], id: "ascenseur", subStepId: "ascenseur-3"),
    "ascenseur-4": GenericRegulationView(title: "Ascenseur", content: [
        RegulationCheckField(key: "ascenseurcatdeux", type: TypeField.bool, text: "Ascenseur type 2: 1.10m x 1.40m avec un passage libre de 90cm", optional: false)], id: "ascenseur", subStepId: "ascenseur-4"),
    "ascenseur-5": GenericRegulationView(title: "Ascenseur", content: [
        RegulationCheckField(key: "ascenseurcattrois", type: TypeField.bool, text: "Ascenseur type 3: 2m x 1.40m avec un passage libre de 1.1m", optional: false)], id: "ascenseur", subStepId: "ascenseur-5"),
    "rampe-1": GenericRegulationView(title: "Choisissez le type de Rampe", content: [
        RegulationCheckField(key: "permanente", type: TypeField.bool, text: "Permanente", optional: false),
        RegulationCheckField(key: "amovible", type: TypeField.bool, text: "Amovible", optional: false),
        RegulationCheckField(key: "posée", type: TypeField.bool, text: "Posée", optional: false),
        RegulationCheckField(key: "intégré", type: TypeField.bool, text: "Intégré (à justifier si la rampe n'est pas intégrée)", optional: false),
        RegulationCheckField(key: "automatique", type: TypeField.bool, text: "Automatique", optional: false)
    ], id: "rampe", subStepId: "rampe-1"),
    "rampe-2": GenericRegulationView(title: "Rampe (pour automatique et amovible)", content: [RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "Hauteur comprise entre 0,90 m et 1,30 m (mesurée depuis l'espace d'emprise de la rampe)", optional: false)], id: "rampe", subStepId: "rampe-2"),
    "rampe-3": GenericRegulationView(title: "Rampe (pour automatique et amovible)", content: [RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "L'usager est informé de la prise en compte de son appel", optional: false)], id: "rampe", subStepId: "rampe-3"),
    "rampe-4": GenericRegulationView(title: "Rampe (pour automatique et amovible)", content: [RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "Les employés de l'établissement sont formés à la manipulation et au deploiement de la rampe", optional: false)], id: "rampe", subStepId: "rampe-4"),
    "rampe-5": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "Le dispositif mis en place pour permettre l'acces est visible et accessible", optional: false)], id: "rampe", subStepId: "rampe-5"),
    "rampe-6": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "airdemanoeuvre", type: TypeField.bool, text: "L'air de manoeuvre en haut et en bas de la rampe respect les dimensions minimale suivante: 1.20 x 1.40", optional: false)], id: "rampe", subStepId: "rampe-6"),
    "rampe-7": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe peut supporter une masse minimal de 300kg", optional: false)], id: "rampe", subStepId: "rampe-7"),
    "rampe-8": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe est suffisament large pour accueillir une personne en fauteuil roulant", optional: false)], id: "rampe", subStepId: "rampe-8"),
    "rampe-9": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe est non-glissante", optional: false)], id: "rampe", subStepId: "rampe-9"),
    "rampe-10": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe est contrastée par son environnement", optional: false)], id: "rampe", subStepId: "rampe-10"),
    "rampe-11": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe est constituée de matériaux opaques", optional: false)], id: "rampe", subStepId: "rampe-11"),
    "rampe-12": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "La rampe doit respecter la règle fonctionelle d'acces à l'angle droit (L1 + L2 > 2m)", optional: false)], id: "rampe", subStepId: "rampe-12"),
    "rampe-13": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Le plan incliné a une largeur minimum de 80cm", optional: true)], id: "rampe", subStepId: "rampe-13"),
    "rampe-14": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Le signalement est situé à proximité de la porte d'entrée", optional: false)], id: "rampe", subStepId: "rampe-14"),
    "rampe-15": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Les signalements sont facilement repérables", optional: false)], id: "rampe", subStepId: "rampe-15"),
    "rampe-16": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Les signalements sont visuellement contrastés vis à vis de son support", optional: false)], id: "rampe", subStepId: "rampe-16"),
    "rampe-17": GenericRegulationView(title: "Rampe", content: [
        RegulationCheckField(key: "massesupportée", type: TypeField.bool, text: "Les signalements sont situés au droit d'une signalisation visuelle (ex: panneau) pour expliciter sa signification", optional: false)], id: "rampe", subStepId: "rampe-17"),
    "rampe-18": GenericRegulationView(title: "Rampe (pour permanente ou posée)", content: [
        RegulationCheckField(key: "dispositif", type: TypeField.bool, text: "La rampe ne présente pas de vide latéraux", optional: false)], id: "rampe", subStepId: "rampe-18")
    ]
