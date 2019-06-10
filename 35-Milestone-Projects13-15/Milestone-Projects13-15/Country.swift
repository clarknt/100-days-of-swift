//
//  Country.swift
//  Milestone-Projects13-15
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let countries = try? newJSONDecoder().decode(Countries.self, from: jsonData)

import Foundation

// MARK: - Country
struct Country: Codable {
    let currencies: [Currency]
    let languages: [Language]
    let flag: String
    let name, alpha2Code, capital: String
    let population: Int
    let demonym: String
    // replace generated distinction between Int and Double by always Double
    let area: Double?
    let nativeName: String
}

// MARK: - Currency
struct Currency: Codable {
    let code, name, symbol: String?
}

// MARK: - Language
struct Language: Codable {
    let iso6391: String?
    let iso6392, name, nativeName: String
    
    enum CodingKeys: String, CodingKey {
        case iso6391 = "iso639_1"
        case iso6392 = "iso639_2"
        case name, nativeName
    }
}

typealias Countries = [Country]
