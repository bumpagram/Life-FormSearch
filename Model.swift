//  ResultsModel.swift
//  Life-FormSearch
//  Created by .b[u]mpagram on 24/2/24.

import Foundation

// SEARCH API JSON Parsing //
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
// --------------------- //



// PAGES API JSON Parsing //
struct PagesResponse: Codable {
    let details: Details    //  ТУТ СЛОВАРИ И ОБЪЕКТЫ ДРУГ В ДРУГА в JSON
    enum CodingKeys: String, CodingKey {
       case details = "taxonConcept"
    }
}

struct Details: Codable {
    var dataObjects: [DataObjects]?
    var taxonConcepts: [TaxonConcepts]?  // просто берем первый элемент
    let scientificName: String   // лучше использовать это поле вместо инфы из Search API-title
}

struct DataObjects: Codable {
    var agents: [Agents]  // просто берем первый элемент
    var pictureURL: URL
    var license: URL
    var rightsHolder: String?

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
// --------------------- //



// HIERARCHY API JSON Parsing //
struct HierarchyResponse: Codable {
    let ancestors: [Ancestors]
}

struct Ancestors: Codable {
    var taxonRank: String?
    var scientificName: String
}
// --------------------- //
