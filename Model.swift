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
