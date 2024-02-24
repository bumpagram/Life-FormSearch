//  ResultsModel.swift
//  Life-FormSearch
//  Created by .b[u]mpagram on 24/2/24.

import Foundation

struct LifeForm: Codable {
    
    var commonName: String
    var id: Int
    var link: URL
    var scientificName: String
    
    enum CodingKeys: String, CodingKey {
        case commonName = "content"
        case id
        case link
        case scientificName = "title"
    }
}

struct SearchResponse: Codable {
    let results: [LifeForm]
}




struct PagesResponse: Codable {
    let details: Details    //  ТУТ СЛОВАРИ И ОБЪЕКТЫ ДРУГ В ДРУГА в JSON
    enum CodingKeys: String, CodingKey {
       case details = "taxonConcept"
    }
}

struct Details: Codable {
    var dataObjects: [DataObjects]?
    var taxonConcepts: [TaxonConcepts]?  // просто берем первый элемент
    let scientificName: String
    // НЕДОДЕЛАН
}

struct DataObjects: Codable {
    var agents: [Agents]  // просто берем первый элемент
    var pictureURL: URL
    var license: URL
    var rightsHolder: String?
    // НЕДОДЕЛАН
    enum CodingKeys: String, CodingKey {
        case agents
        case pictureURL = "eolMediaURL"
        case license
        case rightsHolder
    }
}

struct Agents: Codable {
    var fullName: String
    var role: String
    enum CodingKeys: String, CodingKey {
        case fullName = "full_name"
        case role
    }
}

struct TaxonConcepts: Codable {
    var nameAccordingTo: String
    var identifier: Int     // will be used to request the details of the classification in the hierarchy API.
}

