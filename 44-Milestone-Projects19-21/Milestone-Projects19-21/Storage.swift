//
//  Data.swift
//  Milestone-Projects19-21
//

import Foundation

class Storage {
    static let notesKey = "notes"
    
    // run on background thread
    static func load() -> [Note] {
        let defaults = UserDefaults.standard
        var notes = [Note]()
        
        if let savedData = defaults.object(forKey: notesKey) as? Data {
            let jsonDecoder = JSONDecoder()
            notes = (try? jsonDecoder.decode([Note].self, from: savedData)) ?? notes
        }
        
        return notes
    }
    
    // run on background thread
    static func save(notes: [Note]) {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: notesKey)
        }
    }
}
