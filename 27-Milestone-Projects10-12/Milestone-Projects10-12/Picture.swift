//
//  Picture.swift
//  Milestone-Projects10-12
//

import Foundation

class Picture: Codable {
    var imageName: String
    var caption: String
    
    init(imageName: String, caption: String) {
        self.imageName = imageName
        self.caption = caption
    }
}
