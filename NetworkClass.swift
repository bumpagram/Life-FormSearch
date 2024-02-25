//  NetworkClass.swift
//  Life-FormSearch
//  Created by .b[u]mpagram on 24/2/24.
//
import UIKit
import Foundation


class NetworkClass {
    
    static let shared = NetworkClass() // синглтон, единая точка входа. Положили класс сам в себя, инициализировали. Можно вызывать через NetworkClass.shared для сетевых запросов
    
    func fetchSearchResults(for queryParameters: [String: String]) async throws -> [LifeForm] {

        var urlComponent = URLComponents(string: "https://eol.org/api/search/1.0.json")!
        urlComponent.queryItems = queryParameters.map({ (key: String, value: String) in
            URLQueryItem(name: key, value: value)
        })
        
        let (someData, someResponse) = try await URLSession.shared.data(from: urlComponent.url!)
        guard let httpResponse = someResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ErrorHandler.itemNotFound
        }
        
        let jsondecoder = JSONDecoder()
        let serverAnswer = try jsondecoder.decode(SearchResponse.self, from: someData)
        //someData.prettyPrintedJSONstring()
        return serverAnswer.results
    }
    
    
    func fetchPagesAPI(for element: LifeForm) async throws -> PagesResponse {
        
        var urlComponent = URLComponents(string: "https://eol.org/api/pages/1.0/\(element.id).json")!
        let queryPreset = [
            "images_per_page" : "1",
            "taxonomy" : "true",
            "language" : "en"
           // "details": true   мб понадобится include all metadata for data objects
        ]
        urlComponent.queryItems = queryPreset.map({  URLQueryItem(name: $0.key, value: $0.value)  })
        
        let (someData, someResponse) = try await URLSession.shared.data(from: urlComponent.url!)
        guard let httpResponse = someResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ErrorHandler.pagesAPIerror
        }
        
        let jsondecoder = JSONDecoder()
        let serverAnswer = try jsondecoder.decode(PagesResponse.self, from: someData)
        //someData.prettyPrintedJSONstring()
        return serverAnswer     // возвращаем весь объект с всеми полями по максимуму заполненные метаданными ОДНОГО LifeForm
    }
    
    
    func fetchHierarchyAPI(for identifier: Int) async throws -> HierarchyResponse {
        
        var urlComponent = URLComponents(string: "https://eol.org/api/hierarchy_entries/1.0/\(identifier).json")!
        let queryPreset = [
            "language" : "en"
        ]
        urlComponent.queryItems = queryPreset.map({  URLQueryItem(name: $0.key, value: $0.value)  })
        
        let (someData, someResponse) = try await URLSession.shared.data(from: urlComponent.url!)
        guard let httpResponse = someResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ErrorHandler.hierarchyAPIerror
        }
        let jsondecoder = JSONDecoder()
        let serverAnswer = try jsondecoder.decode(HierarchyResponse.self, from: someData)
        return serverAnswer
    }
    
    
    func fetchImage(from url: URL) async throws -> UIImage {
                    
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw ErrorHandler.noImageData
            }
            guard let createImage = UIImage(data: data) else {
                throw ErrorHandler.noImageData
            }
            
            return createImage
        }
    
}

enum ErrorHandler: Error, LocalizedError {
    case itemNotFound
    case pagesAPIerror
    case hierarchyAPIerror
    case noImageData
}



