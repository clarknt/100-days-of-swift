//
//  UserScript.swift
//  Extension
//

import Foundation

class UserScript: Codable {
    var name: String
    var script: String
    
    init(name: String, script: String) {
        self.name = name
        self.script = script
    }
}
