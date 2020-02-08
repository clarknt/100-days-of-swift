//
//  Note.swift
//  Milestone-Projects19-21
//

import Foundation

class Note: Codable {
    var text: String
    var modificationDate: Date

    init(text: String, modificationDate: Date) {
        self.text = text
        self.modificationDate = modificationDate
    }
}
