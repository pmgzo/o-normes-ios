//
//  BuildingTypeSelection.swift
//  Onormes
//
//  Created by gonzalo on 06/10/2022.
//

import Foundation
import SwiftUI


struct BuildingTypeSelection: View {
    private var _buildingType: Binding<String>;

    
    @Environment(\.presentationMode) var presentationMode
    
    init(buildingType: Binding<String>) {
        _buildingType = buildingType
    }
    
    var body: some View {
        ReturnButtonWrapper {
            ResearchBar(text: _buildingType)
            ScrollView {
                ForEach(searchResults, id: \.self) { buildingType in
                    VStack {
                        Button(buildingType) {
                            _buildingType.wrappedValue = buildingType
                            presentationMode.wrappedValue.dismiss()
                        }.frame(maxWidth: .infinity, maxHeight: 28, alignment: .center)
                        Divider()
                    }.frame(height: 30)
                    
                }
            }.frame(maxWidth: .infinity).background(.white)
        }
    }

    
    var searchResults: [String] {
        if self._buildingType.wrappedValue.isEmpty {
            return buildingTypeList
        } else {
            return buildingTypeList.filter { //$0.contains(searchText)
                let range = NSRange(location: 0, length: $0.utf16.count)
                let pattern  = _buildingType.wrappedValue
                let regex = try! NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
                
                return regex.firstMatch(in: $0, options: [], range: range) != nil
            }
        }
    }
}


let buildingTypeList = [
    "Hôtel",
    "Chambre d’hôtes",
    "Gîtes",
    "Camping",
    "Meublés de tourisme",
    "Appart ‘Hôtel",
    "Auberge de jeunesse",
    "Village de vacances",
    "Hébergements insolites",
    "Restaurant",
    "Restauration rapide",
    "Bar",
    "Attractions / Spectacles",
    "Parc à thème aquatique",
    "Zoo",
    "Aquarium",
    "Aires de jeux enfants",
    "Parcs / Jardin",
    "Baignade plages lacs",
    "Réserve naturelle",
    "Points de vue panoramiques",
    "Plans d'eau",
    "Laser Game",
    "Escape Game",
    "Bowling",
    "Casinos",
    "Monuments (Ponts, arènes, ruines anciennes,sites historiques, quartiers, port …)",
    "Châteaux",
    "Sites sacrés et religieux (Eglises, cathédrales, basiliques, chapelle, couvent, mosquée, synagogues, temples…)",
    "Musées",
    "Tours en bus",
    "Visites de la ville",
    "Croisières",
    "Œnotourisme",
    "Éco-circuits",
    "Visites guidées",
    "Salle de spectacles",
    "Théâtre",
    "Cinéma",
    "Athlétisme",
    "Aviron",
    "Aviron Indoor",
    "Badminton",
    "Basket-ball",
    "Canoë Kayak",
    "Cyclisme / VTT",
    "Equitation",
    "Balade à cheval",
    "Escalade",
    "Escrime",
    "Football",
    "Golf",
    "Haltérophilie",
    "Judo",
    "Natation / Piscine",
    "Parachutisme",
    "Pêche",
    "Pétanque",
    "Plongée sous-marine",
    "Randonnée",
    "Rugby",
    "Ski, raquettes, chiens de traineau",
    "Tennis",
    "Tennis de table",
    "Tir à l'arc",
    "Tir sportif",
    "Voile / Bâteau",
    "Volley-ball",
    "Vol en montgolfière",
    "Vol en parapente",
    "Alimentation générale",
    "Boucherie",
    "Boulangerie",
    "Fromagerie",
    "Magasin bio",
    "Marchés fermiers",
    "Pâtisserie",
    "Poissonnerie",
    "Habillement",
    "Chaussures",
    "Maroquinerie /Bagagerie",
    "Bijouterie",
    "Parfumerie",
    "Esthéticienne",
    "Coiffeur",
    "Bricolage",
    "Ameublement",
    "Décoration",
    "Electro-ménager",
    "Antiquaire / Brocante",
    "Animalerie",
    "Fleuriste et jardinerie",
    "Magasin de musique",
    "Magasin de sport",
    "Boutiques de cadeaux et spécialités",
    "Locations de bateaux",
    "Locations de vélos",
    "Centre commercial",
    "Grands magasins",
    "Optique",
    "Pharmacie",
    "Matériel médical orthopédique",
    "Esthéticienne",
    "Centre de bien-être",
    "Massage/Relaxation",
    "Piscine liée aux ERP",
    "Aéroports",
    "Gares SNCF",
    "Gare routière",
    "Station de métro",
    "Taxis",
    "Ambulance",
    "VSL (Véhicule Sanitaire Léger)",
    "Parking",
    "Assurances",
    "Auto-Ecoles",
    "Banques",
    "Laverie / Pressing",
    "Garage / Contrôle technique",
    "Agence immobilière",
    "Téléphonie",
    "Informatique",
    "Hôpital",
    "Clinique",
    "Médecin",
    "Maison médicale",
    "Dentiste",
    "Sage-femme",
    "Aide-soignant",
    "Audioprothésiste",
    "Auxiliaire de puéricultrice",
    "Diététicien",
    "Ergothérapeute",
    "IDEL",
    "Kinésithérapeute",
    "Orthopédiste-Orthésiste",
    "Orthophoniste",
    "Orthoptiste",
    "Ostéopathe",
    "Pédicure / Podologue",
    "Psychologue",
    "Psychomotricien",
    "Aide à la personne",
    "Avocat",
    "Notaire",
    "Tribunaux",
    "Caisses d’assurance maladie et retraite",
    "Mutuelles",
    "Planning familial",
    "Ecoles",
    "Collèges Lycées",
    "Universités",
    "Ecoles supérieures",
    "Rectorats",
    "Accueil temporaire des personnes handicapées",
    "Foyer de vie ou occupationnel",
    "Foyer d'hébergement pour travailleurs handicapés",
    "Foyer d'accueil médicalisé",
    "Maison d'accueil spécialisée ou MAS",
    "EHPAD",
    "FAM",
    "Moteur",
    "Non-voyants et malvoyants",
    "Sourds  et malentendants"
]
