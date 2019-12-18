//
//  Card.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-07-23.
//  Copyright © 2019 clarknt. All rights reserved.
//

import Foundation

enum CardState {
    case front
    case back
    case matched
    case complete
}

class Card {
    var state: CardState = .back
    
    var backImage: String
    var frontImage: String
    
    init(frontImage: String, backImage: String) {
        self.frontImage = frontImage
        self.backImage = backImage
    }
}
